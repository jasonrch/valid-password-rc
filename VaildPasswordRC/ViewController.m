//
//  ViewController.m
//  VaildPasswordRC
//
//  Created by Julio Reyes on 10/24/15.
//  Copyright © 2015 Julio Reyes. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UITextField *validPasswordTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    RACSignal* isBlacklistedSignal = [[self.validPasswordTextField.rac_textSignal  filter:^BOOL(NSString* text) {
        return text.length > 4;
    }]map:^id(NSString* value) {
        return @([self isBlacklisted:value]);
    }];
    
    RACSignal *validPasswordSignal = [[self.validPasswordTextField.rac_textSignal filter:^BOOL(NSString* text) {
        return text.length > 4;
     }]map:^id(NSString* value) {
         return @([self isValidPassword:value]);
     }];
    
    RAC(self.validPasswordTextField, backgroundColor) = [RACSignal combineLatest:@[isBlacklistedSignal, validPasswordSignal] reduce:^id(NSNumber *isBlacklisted, NSNumber *validPassword){
        return [validPassword boolValue] && ![isBlacklisted boolValue] ? [UIColor greenColor] : [UIColor redColor];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)isBlacklisted: (NSString *)password{
    
    NSArray *blacklist = [NSArray arrayWithObjects:@"A123456a#",@"X123456a@",@"a1234&@56a#",@"a1234&@56a#", nil];
    for (NSString *blacklistedString in blacklist) {
        if ([password isEqualToString:blacklistedString]) {
            return YES;
            break;
        }
    }
    return NO;
}

- (BOOL)isValidPassword:(NSString *)password {
    
    const char firstLetter = [password characterAtIndex:0];
    const char secondLetter = [password characterAtIndex:1];
    
    BOOL textLimitReached = (password.length >= 8 && password.length <= 16);
    BOOL hasNumber = [password rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound; //a
    BOOL doesNotHaveSpace = [password rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location == NSNotFound; //a
    BOOL isEqual = (BOOL)strcmp(&firstLetter, &secondLetter);
    BOOL isLetter = [[NSCharacterSet letterCharacterSet]characterIsMember:[password characterAtIndex:0]];// f
    BOOL containsCharacters = ([password containsString:@"#"] //b1
                               || [password containsString:@"@"] //b2
                               || [password containsString:@"$"] //b3
                               || [password containsString:@"%"] //b4
                               || [password containsString:@"!"] //b5
                               || [password containsString:@"&"]); //b6
    BOOL hasUppercase = [password rangeOfCharacterFromSet:
                         [NSCharacterSet lowercaseLetterCharacterSet]].location != NSNotFound;// g
    BOOL hasLowercase = [password rangeOfCharacterFromSet:
                         [NSCharacterSet uppercaseLetterCharacterSet]].location != NSNotFound; // h
    
    return textLimitReached && hasNumber && doesNotHaveSpace && isLetter && containsCharacters && hasUppercase && hasLowercase && isEqual;
}


@end
