//
//  XYConsoleView.h
//  XYConsoleView
//
//  Created by xiaoyuan on 05/12/2017.
//  Copyright © 2017 xiaoyuan. All rights reserved.
//

#import "XYSuspensionMenu.h"

@class XYConsoleTextView, XYConsoleView;

@interface UIApplication (XYConsole)

@property (nonatomic) XYConsoleView *xy_consoleView;

- (XYConsoleView *)xy_showConsole;
- (BOOL)xy_hideConsole;

@end


@interface XYConsoleTextView : UITextView

@end

@interface XYConsoleView : SuspensionWindow

@property (nonatomic, strong) XYConsoleTextView *consoleTextView;

@property (nonatomic, copy) NSString *text;

@end
