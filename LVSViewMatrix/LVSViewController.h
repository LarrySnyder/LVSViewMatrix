//
//  LVSViewController.h
//  LVSViewMatrix
//
//  Created by Larry Snyder on 9/12/14.
//  Copyright (c) 2014 Larry Snyder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LVSViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIView *matrixView;
@property (nonatomic, weak) IBOutlet UITextField *addRowNum;
@property (nonatomic, weak) IBOutlet UITextField *addColNum;

- (IBAction)handleLayoutCells:(id)sender;
- (IBAction)handleAddRow:(id)sender;
- (IBAction)handleAddCol:(id)sender;

@end
