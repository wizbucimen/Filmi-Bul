//
//  SubmitQuestionViewController.m
//  FilmiBul
//
//  Created by Emre Cimenkaya on 20/02/2018.
//  Copyright © 2018 UpApp. All rights reserved.
//

#import "SubmitQuestionViewController.h"
#import "OYUtils.h"

#define ANSWER_A 11
#define ANSWER_B 12
#define ANSWER_C 13
#define ANSWER_D 14

@import Firebase;
@import FirebaseDatabase;

@interface SubmitQuestionViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *questionTextField;
@property (weak, nonatomic) IBOutlet UITextField *answerATextLabel;
@property (weak, nonatomic) IBOutlet UITextField *answerBTextLabel;
@property (weak, nonatomic) IBOutlet UITextField *answerCTextLabel;
@property (weak, nonatomic) IBOutlet UITextField *answerDTextLabel;

@property (weak, nonatomic) IBOutlet UIButton *aButton;
@property (weak, nonatomic) IBOutlet UIButton *bButton;
@property (weak, nonatomic) IBOutlet UIButton *cButton;
@property (weak, nonatomic) IBOutlet UIButton *dButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@end

@implementation SubmitQuestionViewController{
    NSString *correctAnswer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Gradient
    //========================================================================
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)rgb(0, 68, 87).CGColor, (id)rgb(31, 118, 142).CGColor];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    UILabel *label = [_questionTextField valueForKey:@"_placeholderLabel"];
    label.adjustsFontSizeToFitWidth = YES;
}
    
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Analytics
    //========================================================================
    [OYUtils analyticsSetScreenName:@"SubmitQuestion"];
    [OYUtils activateEdgeSwipe:self isActive:YES];
    
    _questionTextField.placeholder = OYLocale(@"emoji");
    _answerATextLabel.placeholder = OYLocale(@"answer");
    _answerBTextLabel.placeholder = OYLocale(@"answer");
    _answerCTextLabel.placeholder = OYLocale(@"answer");
    _answerDTextLabel.placeholder = OYLocale(@"answer");
    
    [_submitButton setTitle:OYLocale(@"submit") forState:UIControlStateNormal];
    
    _logoImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"filmibul_%@",LANGUAGE_CODE]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.text.length == 0) {
        if ([string isEqualToString:@" "]) {
            return NO;
        }
    }
    
    if (textField == _questionTextField) {
        if ([self isEmoji:string]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        if ([self isEmoji:string]) {
            return NO;
        } else {
            return YES;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - ButtonActions
- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendButtonAction:(id)sender {
    if (_aButton.isSelected || _bButton.isSelected || _cButton.isSelected || _dButton.isSelected) {
        if ([OYUtils isEmptyOrNullString:_questionTextField.text] ||
            [OYUtils isEmptyOrNullString:_answerATextLabel.text] ||
            [OYUtils isEmptyOrNullString:_answerBTextLabel.text] ||
            [OYUtils isEmptyOrNullString:_answerCTextLabel.text] ||
            [OYUtils isEmptyOrNullString:_answerDTextLabel.text] ) {
            
            [OYUtils showAlertMessage:OYLocale(@"submitQuestionMessage") withTitle:OYLocale(@"submitQuestionMessageTitle") okButtonTitle:OYLocale(@"okey") withCancelButtonTitle:nil];

        } else{
            [self submitQuestion];
        }
    } else{
        [OYUtils showAlertMessage:OYLocale(@"submitQuestionRightAnswer") withTitle:OYLocale(@"submitQuestionRightAnswerTitle") okButtonTitle:OYLocale(@"okey") withCancelButtonTitle:nil];
    }
}

- (IBAction)answerButtonAction:(id)sender {
    [_aButton setSelected:NO];
    [_bButton setSelected:NO];
    [_cButton setSelected:NO];
    [_dButton setSelected:NO];
    [sender setSelected:YES];
    
    switch ((int)((UIView*)sender).tag) {
        case ANSWER_A:
            correctAnswer = @"a";
            break;
        case ANSWER_B:
            correctAnswer = @"b";
            break;
        case ANSWER_C:
            correctAnswer = @"c";
            break;
        case ANSWER_D:
            correctAnswer = @"d";
            break;
    }
}

#pragma mark - OtherMethods
- (void)submitQuestion{
    NSDictionary *answers = @{@"a" : _answerATextLabel.text,
                              @"b" : _answerBTextLabel.text,
                              @"c" : _answerCTextLabel.text,
                              @"d" : _answerDTextLabel.text
                              };
    
    NSDictionary *question = @{@"correct_answer" : correctAnswer,
                               @"question" : _questionTextField.text,
                               @"answer" : answers
                               };
    
    SHOW_HUD
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        FIRDatabaseReference *ref = [[FIRDatabase database] reference];
        NSString *key = [[ref child:@"submitted_questions"] child:[self createUniqueQuestionId]].key;
        NSDictionary *childUpdates = @{[NSString stringWithFormat:@"submitted_questions/%@/", key]: question};
        NSLog(@"\n Start \n %@ \nEND ",childUpdates);
        [ref updateChildValues:childUpdates];
        [OYUtils analyticsLogEventWithName:@"Question_Submitted"];

        dispatch_async(dispatch_get_main_queue(), ^(void){
            HIDE_HUD
            [_questionTextField resignFirstResponder];
            [OYUtils showAlertMessage:OYLocale(@"submitted") withTitle:OYLocale(@"oley") okButtonTitle:OYLocale(@"okey") withCancelButtonTitle:nil];
        });
    });
}

- (NSString *)createUniqueQuestionId{
    return [NSString stringWithFormat:@"%@-%@",[OYUtils getTimeFromEpoch:[NSDate date]] ,[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
}

- (BOOL)isEmoji:(NSString *)character {
    UILabel *characterRender = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    characterRender.text = character;
    characterRender.backgroundColor = [UIColor blackColor];//needed to remove subpixel rendering colors
    [characterRender sizeToFit];
    
    CGRect rect = [characterRender bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef contextSnap = UIGraphicsGetCurrentContext();
    [characterRender.layer renderInContext:contextSnap];
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = [capturedImage CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    BOOL colorPixelFound = NO;
    
    int x = 0;
    int y = 0;
    while (y < height && !colorPixelFound) {
        while (x < width && !colorPixelFound) {
            
            NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
            
            CGFloat red = (CGFloat)rawData[byteIndex];
            CGFloat green = (CGFloat)rawData[byteIndex+1];
            CGFloat blue = (CGFloat)rawData[byteIndex+2];
            
            CGFloat h, s, b, a;
            UIColor *c = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
            [c getHue:&h saturation:&s brightness:&b alpha:&a];
            
            b /= 255.0f;
            
            if (b > 0) {
                colorPixelFound = YES;
            }
            
            x++;
        }
        x=0;
        y++;
    }
    return colorPixelFound;
}

@end
