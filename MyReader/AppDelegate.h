//
//  AppDelegate.h
//  MyReader
//
//  Created by YDJ on 13-5-26.
//  Copyright (c) 2013年 NJGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAIntroView.h"
@class RevealController;
@class MBProgressHUD;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UITextFieldDelegate,UIAlertViewDelegate,EAIntroDelegate>
{
    UIView *landingView;
    UITextField *userNameTF;
    UITextField *psdTF;
    UITextField *ipTF;
    NSString *uuidstr;
    NSString *tokenString;
    NSString *postToken;
    
    UILabel *TipLabel;
}
@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
