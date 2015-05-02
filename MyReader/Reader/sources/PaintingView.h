/*
     File: PaintingView.h
 Abstract: The class responsible for the finger painting. The class wraps the 
 CAEAGLLayer from CoreAnimation into a convenient UIView subclass. The view 
 content is basically an EAGL surface you render your OpenGL scene into.
  Version: 1.11
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
*/

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

//CONSTANTS:

#define kBrushOpacity		1			//透明度
#define kBrushPixelStep		2			//移动间距
#define kBrushScale			10			//缩放 越大越小
#define kLuminosity			0.75		//亮度
#define kSaturation			1.0			//饱和度

//CLASS INTERFACES:

@interface PaintingView : UIView
{
@private
	// The pixel dimensions of the backbuffer
	GLint backingWidth;
	GLint backingHeight;
	size_t			width, height;
	EAGLContext *context;
	
	// OpenGL names for the renderbuffer and framebuffers used to render to this view
	GLuint viewRenderbuffer, viewFramebuffer;
	
	// OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
	GLuint depthRenderbuffer;
	
	GLuint	brushTexture;
	CGPoint	location;
	CGPoint	previousLocation;
	Boolean	firstTouch;
	Boolean needsErase;
    Boolean	isRemove;

	
	NSMutableArray *recordPaths;
    NSMutableArray *removePaths;

	NSMutableArray *recordInfos;
	
	//当前颜色
	NSString *curColor;
	//当前用户
	NSString *curUser;
	
	//粗细笔头
	NSString *penImage;
    
    //刷子对象
	CGImageRef		brushImage;
	//刷子上下文
	CGContextRef	brushContext;
	//刷子数据
	GLubyte			*brushData;

}
@property(nonatomic,readwrite)	   Boolean	isRemove;

@property(nonatomic,readwrite)	CGPoint		location;
@property(nonatomic,readwrite)	CGPoint		previousLocation;
@property(nonatomic,retain)		NSString	*curColor;
@property(nonatomic,retain)		NSString	*curUser;
@property (nonatomic,retain) NSString *penImage;
@property(nonatomic,readwrite)  GLuint viewRenderbuffer;
//设置刷子颜色
//- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alp;
//清屏
- (void)erase;
//清路径
- (void)clearPaths;
//undo操作
- (void)undoData;
//加载路径文件
- (void)loadPaths:(NSString *)path DateName:(NSString *)dateName;
//保存路径文件
- (NSString *)savePaths:(NSString *)path DateName:(NSString *)dateName;
- (void)savePaths:(NSString *)path DateName:(NSString *)dateName AyPartData:(NSArray*)ayPartData AyPartInfo:(NSArray *) ayPartInfo;

//粗细
- (void)thickness:(float)Width :(float)Height;
//画图
//- (void)plotting;
@end
