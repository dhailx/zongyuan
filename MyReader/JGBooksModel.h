//
//  JGBooksModel.h
//  MyReader
//
//  Created by YDJ on 13-5-22.
//  Copyright (c) 2013年 NJGuo. All rights reserved.
//




#import <Foundation/Foundation.h>
/*
 <books>
 <category>
 <cateName>计算机类</cateName>
 <bookList>
 <bookInfo>
 <bookName>计算机书的名字</bookName>
 <author>计算机书的作者</author>
 </bookInfo>
 </bookList>
 </category>
 <category>
 <cateName>水利类</cateName>
 <bookList>
 <bookInfo>
 <bookName>水利书的名字</bookName>
 <author>水利书的作者</author>
 </bookInfo>
 </bookList>
 </category>
 </books>
 
 */
@interface JGBooksModel : NSObject

@end

//books为xml的根节点，根据命名可以更换
@interface Books : JGBooksModel

@property (nonatomic,strong)NSMutableArray * categoryList;//里面存放CategoryBook

@end


@interface CategoryBook : NSObject

@property (nonatomic,copy)NSString * cateName;
@property (nonatomic,strong)NSMutableArray * bookList;//里面存放bookInfo

@end


