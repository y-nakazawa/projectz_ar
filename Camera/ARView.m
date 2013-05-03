//
//  ARVIew.m
//  AR
//
//  Created by 中澤 祐一 on 13/03/21.
//  Copyright (c) 2013年 中澤 祐一. All rights reserved.
//

#import "ARVIew.h"

@implementation ARView

//--------------------------------------------------------------//
#pragma mark -- Initialize --
//--------------------------------------------------------------//
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void) _init
{
    // レイヤーを設定する
    CAEAGLLayer* eagLayer;
    eagLayer = (CAEAGLLayer*) self.layer;
    eagLayer.opaque = NO;
    eagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil
    ];
    
    // OpenGLコンテキストを作成する
    _context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES1];
    [EAGLContext setCurrentContext:_context];
    
    // フレームバッファを作成する
    glGenFramebuffersOES(1, &_defaultFramebuffer);
    glGenRenderbuffersOES(1, &_colorRenderbuffer);

    // フレームバッファを作成する
    glGenFramebuffersOES(1, &_defaultFramebuffer);
    glGenRenderbuffersOES(1, &_colorRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _defaultFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _colorRenderbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(
                                 GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _colorRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &_backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &_backingHeight);
    
    // 情報表示のためのラベルを作成する
    _label = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, 440.0f, 304.0f, 40.0f)];
    _label.textColor = [UIColor whiteColor];
    _label.backgroundColor = [UIColor blackColor];
    [self addSubview:_label];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    // 初期化
    [self _init];
    
    return self;
}

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    // 初期化
    [self _init];
    
    return self;
}

//--------------------------------------------------------------//
#pragma mark -- Drawing --
//--------------------------------------------------------------//
- (void)drawView:(id)sender
{
    // 現在のコンテキストを作成する
    if ([EAGLContext currentContext] != _context) {
        [EAGLContext setCurrentContext:_context];
    }
    
    // フレームバッファを設定する
    glBindFramebuffer(GL_FRAMEBUFFER_OES, _defaultFramebuffer);
    
     // 視点の設定をする
    glViewport(0, 0, _backingWidth, _backingHeight);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // カラーバッファをクリア
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 射影変換の設定をする
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(-1.0f, 1.0f, -1.5f, 1.5f, 0, 10.0f);
    
    // モデルビューを設定する
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    // 加速度による回転を行う
    glRotatef(_gravity.z * -90.0f, 1.0f, 0, 0);
    
    // 電子コンパスによる回転を行う
    glRotatef(_heading, 0, 1.0f, 0);
    
    // ポリゴンを作成する
    for (int i = 0; i < 16; i++) {
        // 現在の行列を保存する
        glPushMatrix();
        
        // オブジェクトの位置を決定する
        glRotatef(360.0f / 16 * i, 0, 1.0f, 0);
        glTranslatef(0, 0, -2.0f);
        
        // ポリゴンの頂点を設定する
        GLfloat vleft, vright, vtop, vbottom;
        vleft = -0.2f;
        vright = 0.2f;
        vtop = -0.2f;
        vbottom = 0.2f;
        GLfloat squareVertices[] = {
            vleft, vbottom,
            vright, vbottom,
            vleft, vtop,
            vright, vtop,
        };
        glVertexPointer(2, GL_FLOAT, 0, squareVertices);
        
        // ポリゴンの色を設定する
        const GLubyte squareColors[] = {
            16 * i, 255 - (16 * i), 255, 255,
            16 * i, 255 - (16 * i), 255, 255,
            16 * i, 255 - (16 * i), 255, 255,
            16 * i, 255 - (16 * i), 255, 255,
        };
        glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
        
        // ポリゴンを描画する
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        
        // 現在のモデルビューマトリックスを取得する
        GLfloat mm[16];
        glGetFloatv(GL_MODELVIEW_MATRIX, mm);
        
        // 変換する頂点を4x4行列で用意する
        GLfloat ov[] = {
            vleft, vbottom, 0, 1.0f,
            vright, vbottom, 0, 1.0f,
            vleft, vtop, 0, 1.0f,
            vright, vtop, 0, 1.0f,
        };
        
        // モデルビューマトリックスを用いて変換する
        for (int j = 0; j < 4; j++) {
            // 頂点行列の一行を取得する
            GLfloat v[4];
            v[0] = ov[j * 4];
            v[1] = ov[j * 4 + 1];
            v[2] = ov[j * 4 + 2];
            v[3] = ov[j * 4 + 3];
            
            // 変換の計算を行う
            GLfloat mv[4];
            mv[0] = v[0] * mm[0] + v[1] * mm[4] + v[2] * mm[8] + v[3] * mm[12];
            mv[1] = v[0] * mm[1] + v[1] * mm[5] + v[2] * mm[9] + v[3] * mm[13];
            mv[2] = v[0] * mm[2] + v[1] * mm[6] + v[2] * mm[10] + v[3] * mm[14];
            mv[3] = v[0] * mm[3] + v[1] * mm[7] + v[2] * mm[11] + v[3] * mm[15];
            
            // x、y座標を保存する
            _translatedRects[i][j * 2] = mv[0];
            _translatedRects[i][j * 2 + 1] = mv[1];
        }
        
        
        // 以前の行列に戻す
        glPopMatrix();
    }
    
    // バッファを描画する
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _defaultFramebuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
    // OpenGLの状態を無効化する
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    // ラベルをクリアする
    _label.text = @"";
    
    // タッチした座標を取得する
    CGPoint point;
    point = [[touches anyObject] locationInView:self];
    
    // OpenGL座標系に変換する
    float   x, y;
    x = (point.x - 160.0f) / 160.0f;
    y = (240.0f - point.y) / 160.0f;
    
    // 変換された矩形領域と比較する
    int i;
    for (i = 0; i < 16; i++) {
        // 矩形の頂点を取得する
        float   x0, y0, x3, y3;
        x0 = _translatedRects[i][0];
        y0 = _translatedRects[i][1];
        x3 = _translatedRects[i][6];
        y3 = _translatedRects[i][7];
        
        // タッチした座標が矩形領域に含まれる場合
        if (x > x0 && x < x3 && y > y3 && y < y0) {
            // ラベルにメッセージを表示する
            _label.text = [NSString stringWithFormat:@"Touched No. %d rect", i];
            
            break;
        }
    }
}

//--------------------------------------------------------------//
#pragma mark -- Animation --
//--------------------------------------------------------------//
-(void) startAnimation
{
    // ディスプレイリンクを有効化する
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
    [_displayLink setFrameInterval:1];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}


- (void)stopAnimation
{
    // ディスプレイリンクを無効化する
    [_displayLink invalidate], _displayLink = nil;
}
@end
