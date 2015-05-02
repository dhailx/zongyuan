#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "PaintingView.h"
#import "GTMBase64.h"
//CLASS IMPLEMENTATIONS:

// A class extension to declare private methods
//A类扩展申报私有方法
@interface PaintingView (private)


- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;

@end

@implementation PaintingView

@synthesize location,isRemove;
@synthesize previousLocation;
@synthesize curColor;
@synthesize curUser;
@synthesize penImage;
@synthesize viewRenderbuffer;

// Sets up an array of values to use as the sprite vertices.
const GLfloat spriteVerticesP[] = {
    -0.5f, -0.5f,
    0.5f, -0.5f,
    -0.5f,  0.5f,
    0.5f,  0.5f,
};

// Sets up an array of values for the texture coordinates.
const GLshort spriteTexcoordsP[] = {
    0, 0,
    1, 0,
    0, 1,
    1, 1,
};


// Implement this to override the default layer class (which is [CALayer class]).
// We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+ (Class)layerClass {
	return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame {

	
    
    if ((self = [super initWithFrame:frame])) {
		//画布
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
		eaglLayer.opaque = YES;
		// In this application, we want to retain the EAGLDrawable contents after a call to presentRenderbuffer.
		//在此应用中，我们要保留调用到presentRenderbuffer后EAGLDrawable内容。
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		if (!context || ![EAGLContext setCurrentContext:context]) {
			[self release];
			return nil;
		}
		
		// Create a texture from an image
		// First create a UIImage object from the data in a image file, and then extract the Core Graphics image
		//从图像创建一个纹理
		//首先创建一个UIImage对象从一个图像文件的数据，然后提取核心图形图像

		brushImage = [UIImage imageNamed:@"Particle"].CGImage;

		
		// Get the width and height of the image
		//获取图像的宽度和高度
//		width = CGImageGetWidth(brushImage);
//		height = CGImageGetHeight(brushImage);
		width = 30.0f;
        height= 30.0f;
		// Texture dimensions must be a power of 2. If you write an application that allows users to supply an image,
		// you'll want to add code that checks the dimensions and takes appropriate action if they are not a power of 2.
		//纹理尺寸必须是2的乘方。如果你写一个应用程序，允许用户提供图像，
		//你要添加的代码检查的尺寸，并采取适当行动，如果他们是不是2的乘方。
		
		// Make sure the image exists
		//确保图像的存在
//		if(!brushImage) {
			// Allocate  memory needed for the bitmap context
			//分配所需的内存位图背景
			brushData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
			// Use  the bitmatp creation function provided by the Core Graphics framework. 
			//使用Core Graphics框架所提供的bitmatp创造功能
			brushContext = CGBitmapContextCreate(brushData, width, height, 8, width * 4, CGImageGetColorSpace(brushImage), kCGImageAlphaPremultipliedLast);
			// After you create the context, you can draw the  image to the context.
			//创建上下文后，您可以绘制图像的背景
			CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), brushImage);
			// You don't need the context at this point, so you need to release it to avoid memory leaks.
			//你不需要在这一点上的背景下，所以你需要将它释放，以避免内存泄漏
			CGContextRelease(brushContext);
			// Use OpenGL ES to generate a name for the texture.
			//使用OpenGL ES的生成纹理的名称
			glGenTextures(1, &brushTexture);
			// Bind the texture name. 
			//绑定纹理名称
			glBindTexture(GL_TEXTURE_2D, brushTexture);
			// Set the texture parameters to use a minifying filter and a linear filer (weighted average)
			//设置纹理参数，使用minifying滤波器和一个线性的文件管理器（加权平均）
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			// Specify a 2D texture image, providing the a pointer to the image data in memory
			//指定一个2D纹理图像在内存中的图像数据，提供了一个指针
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, brushData);
			// Release  the image data; it's no longer needed
			//释放的图像数据，它不再需要
            free(brushData);
//		}
		
		// Set the view's scale factor
 
		self.contentScaleFactor = 1.0;
		
		// Setup OpenGL states
		glMatrixMode(GL_PROJECTION);
		CGRect frame = self.bounds;
		CGFloat scale = self.contentScaleFactor;
		// Setup the view port in Pixels
		glOrthof(0, frame.size.width * scale, 0, frame.size.height * scale, -1, 1);
		glViewport(0, 0, frame.size.width * scale, frame.size.height * scale);
		glMatrixMode(GL_MODELVIEW);
		
		glDisable(GL_DITHER);
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_VERTEX_ARRAY);
		
	    glEnable(GL_BLEND);
		// Set a blending function appropriate for premultiplied alpha pixel data
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		
		glEnable(GL_POINT_SPRITE_OES);
		glTexEnvf(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE);
        //粗细
		glPointSize(width / kBrushScale);
		
		// Make sure to start with a cleared buffer
		needsErase = YES;
		
		//初始化记录路径
		recordPaths = [[NSMutableArray alloc] init];
        removePaths =  [[NSMutableArray alloc] init];
		recordInfos = [[NSMutableArray alloc] init];
        isRemove = NO;
	}
	
	return self;
}

//cuxi
- (void)thickness:(float)Width :(float)Height{

    width = Width;
    height= Height;
    glPointSize(width / kBrushScale);
    

}

// If our view is resized, we'll be asked to layout subviews.
// This is the perfect opportunity to also update the framebuffer so that it is
// the same size as our display area.
//如果我们认为大小，我们会要求布局子视图。
//这是一个完美的机会，也更新了framebuffer，因此，它是
//作为我们的显示区域大小相同。
- (void)layoutSubviews {
	[EAGLContext setCurrentContext:context];
	[self destroyFramebuffer];
	[self createFramebuffer];
	// Clear the framebuffer the first time it is allocated
	//清除framebuffer的首次分配
	if (needsErase) {
		[self erase];
		needsErase = NO;

	}
}

- (BOOL)createFramebuffer {
	// Generate IDs for a framebuffer object and a color renderbuffer
	//生成一个帧缓冲对象和颜色renderbuffer的标识
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	// This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
	// allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
	//这个调用联营公司目前与EAGLDrawable的渲染缓冲存储（我们CAEAGLLayer）
	//让我们画成一个缓冲区稍后将呈现筛选层是地方（这与我们的观点相对应）。
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	// For this sample, we also need a depth buffer, so we'll create and attach one via another renderbuffer.
	//对于这个示例，我们还需要一个深度缓冲区，所以我们将创建并附加通过另一个renderbuffer之一。
	glGenRenderbuffersOES(1, &depthRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
	
	if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}

// Clean up any buffers we have allocated.
//清理所有已分配的缓冲区。
- (void)destroyFramebuffer {
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	if (depthRenderbuffer) {
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}

// Releases resources when they are not longer needed.
- (void)dealloc {
	if (brushTexture) {
		glDeleteTextures(1, &brushTexture);
		brushTexture = 0;
	}
	if ([EAGLContext currentContext] == context) {
		[EAGLContext setCurrentContext:nil];
	}
	[context release];
	[self.curColor release];
	[self.curUser release];
	[recordPaths release];
	[recordInfos release];
	[penImage release];
	[super dealloc];
}

// Erases the screen
//清除屏幕
- (void)erase {
	[EAGLContext setCurrentContext:context];
	// Clear the buffer
	//清除缓冲区
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT);
	// Display the buffer88
	//显示缓冲区
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

// Drawings a line onscreen based on where the user touches
//图根据用户触摸屏幕的行
- (void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end {
	static GLfloat*		vertexBuffer =NULL;
	static NSUInteger	vertexMax = 64;
	NSUInteger			vertexCount = 0,
	count,
	i;
	
	[EAGLContext setCurrentContext:context];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	
	// Convert locations from Points to Pixels
	//转换从点到像素的位置
	CGFloat scale = self.contentScaleFactor;
	start.x *= scale;
	start.y *= scale;
	end.x *= scale;
	end.y *= scale;
	
	// Allocate vertex array buffer
	//分配顶点数组缓冲区
	if (vertexBuffer == NULL)
		vertexBuffer = malloc(vertexMax * 2 * sizeof(GLfloat));
	
	// Add points to the buffer so there are drawing points every X pixels
	//添加的缓冲区，所以有画点每隔X像素点
	count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / kBrushPixelStep), 1);
	for (i = 0; i < count; ++i) {
		if (vertexCount == vertexMax) {
			vertexMax = 2 * vertexMax;
			vertexBuffer = realloc(vertexBuffer, vertexMax * 2 * sizeof(GLfloat));
		}
		vertexBuffer[2 * vertexCount + 0] = start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)count);
		vertexBuffer[2 * vertexCount + 1] = start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)count);
		vertexCount += 1;
	}
	
	// Render the vertex array
	//渲染的顶点数组
	glVertexPointer(2, GL_FLOAT, 0, vertexBuffer);
	glDrawArrays(GL_POINTS, 0, (int)vertexCount);
	
	// Display the buffer
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

// Drawings a line onscreen based on where the user touches
//图根据分块
- (void)renderLineFromPartIndex:(int)partIndex {
	//指针数量
	int pointCount = (int)[[recordPaths objectAtIndex:partIndex] count];
	
	static GLfloat*		vertexBuffer = NULL;
	static NSUInteger	vertexMax = 64;
	NSUInteger			vertexCount = 0;
	
	vertexMax = 64 * pointCount;
	
	[EAGLContext setCurrentContext:context];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	
	for (int j=0; j<pointCount-1; j++) {
		CGPoint start = [[[recordPaths objectAtIndex:partIndex] objectAtIndex:j] CGPointValue];
		CGPoint end = [[[recordPaths objectAtIndex:partIndex] objectAtIndex:j+1] CGPointValue];
		
		CGFloat scale =self.contentScaleFactor;
		start.x *= scale;
		start.y *= scale;
		end.x *= scale;
		end.y *= scale;
		
		// Allocate vertex array buffer
		//分配顶点数组缓冲区
		if (vertexBuffer == NULL)
			vertexBuffer = malloc(vertexMax * 2 * sizeof(GLfloat));
		
		// Add points to the buffer so there are drawing points every X pixels
		//添加的缓冲区，所以有画点每隔X像素点
		NSUInteger count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / kBrushPixelStep), 1);
		for (int k = 0; k < count; ++k) {
			if (vertexCount == vertexMax) {
				vertexMax = 2 * vertexMax;
				vertexBuffer = realloc(vertexBuffer, vertexMax * 2 * sizeof(GLfloat));
			}
			vertexBuffer[2 * vertexCount + 0] = start.x + (end.x - start.x) * ((GLfloat)k / (GLfloat)count);
			vertexBuffer[2 * vertexCount + 1] = start.y + (end.y - start.y) * ((GLfloat)k / (GLfloat)count);
			vertexCount += 1;
		}
	}
	
	//读取信息
	NSString *onePartInfo = [recordInfos objectAtIndex:partIndex];
	NSString *onePartInfoColor = [[onePartInfo componentsSeparatedByString:@"|"] objectAtIndex:0];
	if ([onePartInfoColor isEqualToString:@"red"]) {
        [self setBrushColorWithRed:1.0f green:0.0f blue:0.0f alpha:1];	}
	if ([onePartInfoColor isEqualToString:@"black"]) {
        [self setBrushColorWithRed:0.0f green:0.0f blue:0.0f alpha:1];	}
	if ([onePartInfoColor isEqualToString:@"blue"]) {
        [self setBrushColorWithRed:0.0f green:0.0f blue:1.0f alpha:1];
	}
	
    
    
   	// Render the vertex array
	//渲染的顶点数组
	glVertexPointer(2, GL_FLOAT, 0, vertexBuffer);
	glDrawArrays(GL_POINTS, 0, vertexCount);
	
	// Display the buffer
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

// Handles the start of a touch
//处理触摸开始
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //设置颜色
//    if ([self.curColor isEqualToString:@"red"]) {
//        [self setBrushColorWithRed:1.0f green:0.0f blue:0.0f];
//    }
//    if ([self.curColor isEqualToString:@"black"]) {
//        [self setBrushColorWithRed:0.0f green:0.0f blue:0.0f];
//    }
//    if ([self.curColor isEqualToString:@"blue"]) {
//        [self setBrushColorWithRed:0.0f green:0.0f blue:1.0f];
//    }


	CGRect	bounds = [self bounds];
    UITouch *touch = [[event touchesForView:self] anyObject];
	firstTouch = YES;
	// Convert touch point from UIView referential to OpenGL one (upside-down flip)
	//转换从UIView的触摸点参考（颠倒上下翻转的OpenGL）
	location = [touch locationInView:self];
	location.y = bounds.size.height - location.y;
	
}
// Handles the continuation of a touch.
//处理一个触摸的延续。
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //设置颜色
    
    if ([self.curColor isEqualToString:@"red"]) {
        [self setBrushColorWithRed:1.0f green:0.0f blue:0.0f alpha:1];
    }
    else if ([self.curColor isEqualToString:@"black"]) {
        [self setBrushColorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
    }
   else if ([self.curColor isEqualToString:@"blue"]) {
        [self setBrushColorWithRed:0.0f green:0.0f blue:1.0f alpha:1];
    }
   else if ([self.curColor isEqualToString:@"clear"]) {
        [self setBrushColorWithRed:0.0f green:0.0f blue:0.0f alpha:0];
   }else{
       
        [self setBrushColorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
   }
    

	CGRect	bounds = [self bounds];
	UITouch *touch = [[event touchesForView:self] anyObject];
	// Convert touch point from UIView referential to OpenGL one (upside-down flip)
	//转换从UIView的触摸点参考（颠倒上下翻转的OpenGL）
	
//    if (!isRemove) {
        if (firstTouch) {
            
            
            firstTouch = NO;
            previousLocation = [touch previousLocationInView:self];
            previousLocation.y = bounds.size.height - previousLocation.y;
            
            //增加路径
            NSMutableArray *onePartData = [[NSMutableArray alloc] init];
            [recordPaths addObject:onePartData];
            [onePartData release],onePartData = nil;
            [[recordPaths objectAtIndex:[recordPaths count]-1] addObject:[NSValue valueWithCGPoint:previousLocation]];
            
            //增加信息
            NSString *onePartInfo = [NSString stringWithFormat:@"%@|%@",self.curColor,self.curUser];
            [recordInfos addObject:onePartInfo];
            
            
        }
        else {
            location = [touch locationInView:self];
            location.y = bounds.size.height - location.y;
            previousLocation = [touch previousLocationInView:self];
            previousLocation.y = bounds.size.height - previousLocation.y;
            
            //增加路径
            [[recordPaths objectAtIndex:[recordPaths count]-1] addObject:[NSValue valueWithCGPoint:previousLocation]];
            
            // Render the stroke
            //渲染
            [self renderLineFromPoint:previousLocation toPoint:location];
        }
        NSLog(@"qqqqqqqqq%lu",(unsigned long)recordPaths.count );
    
	
}
// Handles the end of a touch event when the touch is a tap.
//处理触摸事件结束时触摸水龙
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGRect	bounds = [self bounds];
    UITouch	*touch = [[event touchesForView:self] anyObject];
	if (firstTouch) {
		firstTouch = NO;
		previousLocation = [touch previousLocationInView:self];
		previousLocation.y = bounds.size.height - previousLocation.y;
		[self renderLineFromPoint:previousLocation toPoint:location];
	}
}
// Handles the end of a touch event.
//处理触摸事件结束。
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	// If appropriate, add code necessary to save the state of the application.
	// This application is not saving state.
	//如果合适的话，添加必要的代码保存应用程序的状态。
	//此应用程序是不节能状态。
}

- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alp{
	// Set the brush color using premultiplied alpha values
	//设置画笔颜色，使用预乘alpha值
	glColor4f(red * alp, green * alp, blue * alp, alp);
}

//加载路径文件
- (void)loadPaths:(NSString *)path DateName:(NSString *)dateName{
	
//	NSString *appPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/"]; //@""
	NSString *appPath = [path stringByAppendingString:@"/"];
	NSString *dataPath = [appPath stringByAppendingString:[NSString stringWithFormat:@"data:%@",dateName]];
	NSString *infoPath = [appPath stringByAppendingString:[NSString stringWithFormat:@"info:%@",dateName]];
    NSLog(@"%@",dataPath);
	//清屏
	[self erase];
	[self clearPaths];
	//加载路径文件转换为数组并重绘
	NSMutableArray *ayPartData = [NSMutableArray arrayWithContentsOfFile:dataPath];
	NSMutableArray *ayPartInfo = [NSMutableArray arrayWithContentsOfFile:infoPath];
	if ([ayPartData count] > 0) {
		//文件内容转换为路径数组
		for(int i=0; i<[ayPartData count]; i++) {
			NSData		*data = [ayPartData objectAtIndex:i];
        
        data = [GTMBase64 decodeData:data];
			CGPoint		*point = (CGPoint*)[data bytes];
			NSUInteger	count = [data length] / sizeof(CGPoint);
      
			NSMutableArray *onePartPath = [[NSMutableArray alloc] init];
			//导出路径数据
			for(int j = 0; j < count; j++,++point) {
				[onePartPath addObject:[NSValue valueWithCGPoint:*point]];
			}
			[recordPaths addObject:onePartPath];
			//导出信息数据
            NSLog(@"%lu",(unsigned long)ayPartInfo.count);
			NSString *onePartInfo = [ayPartInfo objectAtIndex:0];
			[recordInfos addObject:onePartInfo];
//			[onePartPath release],onePartPath = nil;
		}
		//分块加载
		for (int i=0; i<[ayPartData count]; i++) {
			[self renderLineFromPartIndex:i];
		}
	}
}
//保存路径文件
- (NSString *)savePaths:(NSString *)path DateName:(NSString *)dateName{
    
	NSString *appPath = [path stringByAppendingString:@"/"]; //@""
	NSString *dataPath = [appPath stringByAppendingString:[NSString stringWithFormat:@"data:%@",dateName]];
	NSString *infoPath = [appPath stringByAppendingString:[NSString stringWithFormat:@"info:%@",dateName]];
	NSMutableString *tmpStr = [[NSMutableString alloc] init];
    NSMutableString *tmpStr2 = [[NSMutableString alloc] init];
	NSMutableArray *ayPartData = [[NSMutableArray alloc] init];
	NSMutableArray *ayPartInfo = [[NSMutableArray alloc] init];
	int partCount = (int)[recordPaths count];
    NSLog(@"%@",recordPaths);
   	for (int i=0; i<partCount; i++)
    {
		int pointCount = (int)[[recordPaths objectAtIndex:i] count];
		//分配point数组内存空间
		CGPoint *points = malloc(sizeof(CGPoint)*pointCount);
		for (int j=0; j<pointCount; j++) {
			points[j] = [[[recordPaths objectAtIndex:i] objectAtIndex:j] CGPointValue];
		}
//		NSData *data = [NSData dataWithBytes:points length:sizeof(*points)*pointCount];
        NSData *data = [GTMBase64 encodeBytes:points length:sizeof(*points)*pointCount];
        NSString *dataStr = [GTMBase64 stringByEncodingData:data];
        NSLog(@"%@",dataStr);
//        NSString *dataStr = 
        [tmpStr appendString:[NSString stringWithFormat:@"%@*",dataStr]];
        NSLog(@"%@",tmpStr);

		free(points);
		[ayPartData addObject:data];
		[ayPartInfo addObject:[recordInfos objectAtIndex:i]];
        [tmpStr2 appendString:[recordInfos objectAtIndex:i]];
	}
    NSLog(@"%@",ayPartData);
//    NSString *tmp = (NSString*)tmpStr;
//    NSString *tmp2 = (NSString*)tmpStr2;

   NSString *tmp = [tmpStr stringByReplacingOccurrencesOfString:@"" withString:@""];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"" withString:@""];
    NSString *tmp2 = [tmpStr2 stringByReplacingOccurrencesOfString:@"" withString:@""];
    tmp2 = [tmp2 stringByReplacingOccurrencesOfString:@"" withString:@""];
//    NSLog(@"%@",tmp);

	[ayPartData writeToFile:dataPath atomically:YES];
    NSLog(@"%@",ayPartData);
	[ayPartInfo writeToFile:infoPath atomically:YES];


//	[ayPartData release],ayPartData = nil;
//	[ayPartInfo release],ayPartInfo = nil;
    NSString *str = [[NSString alloc] initWithFormat:@"%@$$%@",tmp,tmp2 ];
    return str;
  
}

- (void)savePaths:(NSString *)path DateName:(NSString *)dateName AyPartData:(NSArray*)ayPartData AyPartInfo:(NSArray *) ayPartInfo
{
    NSLog(@"%@",ayPartInfo);

    NSString *appPath = [path stringByAppendingString:@"/"]; //@""
	NSString *dataPath = [appPath stringByAppendingString:[NSString stringWithFormat:@"data:%@",dateName]];
	NSString *infoPath = [appPath stringByAppendingString:[NSString stringWithFormat:@"info:%@",dateName]];
    NSMutableArray *ayArr = [[NSMutableArray alloc] init];
  
    NSLog(@"%@",ayPartData);
    for (int i =0; i<ayPartData.count; i++) {
        NSLog(@"%@",[ayPartData objectAtIndex:i]);
        
        NSMutableString *tmp =[[NSMutableString alloc] init];
        [tmp appendString:[ayPartData objectAtIndex:i]];

        NSData *ayStr = [GTMBase64 decodeString:tmp];
        [ayArr addObject:ayStr];
    }
	[ayArr writeToFile:dataPath atomically:YES];
	[ayPartInfo writeToFile:infoPath atomically:YES];
    
//	[ayPartData release],ayPartData = nil;
//	[ayPartInfo release],ayPartInfo = nil;

}
//回退
- (void)undoData {
	//清屏
//    NSLog(@"qqqqqqqqq%@",recordPaths);
	[self erase];
	//移除路径数组最后一次操作并重绘
	if ([recordPaths count] > 0){
		[recordPaths removeLastObject];
		[recordInfos removeLastObject];
        
		//分块加载
		for (int i=0; i<[recordPaths count]; i++) {
			[self renderLineFromPartIndex:i];
		}
	}
}
//清除路径
- (void)clearPaths {
	[recordPaths removeAllObjects];
	[recordInfos removeAllObjects];
}

@end