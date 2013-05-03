//
//  ARVIew.h
//  AR
//
//  Created by 中澤 祐一 on 13/03/21.
//  Copyright (c) 2013年 中澤 祐一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface ARView : UIView
{
    // デバイスの位置情報
/*
    float           _roll;
    float           _pitch;
    float           _yaw;
    CMAcceleration  _gravity;
    float           _heading;
*/ 
    EAGLContext* _context;
    GLint _backingWidth;
    GLint _backingHeight;
    GLuint          _defaultFramebuffer;
    GLuint          _colorRenderbuffer;
    
    // OpenGL
    CADisplayLink*   _displayLink;
    GLfloat _translatedRects[16][8];
    
    // サブビュー
    UILabel*        _label;
}
//@property (strong, nonatomic) EAGLContext* _context;
//@property (weak, nonatomic) GLint _backingWidth;
//@property (strong, nonatomic) GLint _backingHeight;
//@property (strong, nonatomic) GLuint _defaultFramebuffer;
//@property (strong, nonatomic) GLuint _colorRenderbuffer;

// プロパティ
@property (nonatomic) CMAcceleration gravity;
@property (nonatomic) float heading;
@property (nonatomic) float roll;
@property (nonatomic) float pitch;
@property (nonatomic) float yaw;

-(void) startAnimation;
-(void) stopAnimation;
@end
