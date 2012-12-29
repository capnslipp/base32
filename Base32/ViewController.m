/*
 * ViewController.m
 *
 * MIT License (MIT)
 *
 * Copyright (c) 2012 Ashkan Farhadtouski
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

#import <QuartzCore/QuartzCore.h>

#import "ViewController.h"

#import "Base32.h"


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.numberToEncodeTextField.backgroundColor = [UIColor whiteColor];
    self.numberToEncodeTextField.layer.cornerRadius = 8;
    self.numberToEncodeTextField.layer.borderColor = [UIColor grayColor].CGColor;
    self.numberToEncodeTextField.layer.borderWidth = 1;
    
    self.stringToDecodeTextView.layer.cornerRadius = 10;
    self.stringToDecodeTextView.layer.borderColor = [UIColor grayColor].CGColor;
    self.stringToDecodeTextView.layer.borderWidth = 1;
    
    self.decodedNumberTextView.layer.cornerRadius = 10;
    self.decodedNumberTextView.layer.borderColor = [UIColor grayColor].CGColor;
    self.decodedNumberTextView.layer.borderWidth = 1;
    
    // Some predefined tests
    NSString *firstString = @"1234";
    NSString *firstEncodedString = @"16J";
    NSString *secondString = @"1234567890";
    NSString *secondEncodedString = @"14SC0PJ";
    
    // Encode the first string
    NSString *firstTest = [Base32 encode:firstString];
    NSLog(@"'%@' => '%@', Expecting = '16J', %@", firstString, firstTest, [firstTest isEqualToString:firstEncodedString] ? @"Passed" : @"Failed" );
    
    // Encoding using the NSString utility method
    NSString *secondTest = [secondString base32EncodedString];
    NSLog(@"'%@' => '%@', Expecting = '14SC0PJ', %@", secondString, secondTest, [secondTest isEqualToString:secondEncodedString] ? @"Passed" : @"Failed");
    
    // Decode the first string
    NSString *thirdTest = [Base32 decode:firstEncodedString];
    NSLog(@"'%@' => '%@', Expecting = '1234', %@", firstEncodedString, thirdTest, [thirdTest isEqualToString:firstString] ? @"Passed" : @"Failed");
    
    // Decode using the NSString utility method
    NSString *fourthTest = [secondEncodedString decodeBase32String];
    NSLog(@"'%@' => '%@', Expecting = '1234567890', %@", secondEncodedString, fourthTest, [fourthTest isEqualToString:secondString] ? @"Passed" : @"Failed");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)encodeButtonTouchUpInside
{
    self.stringToDecodeTextView.text = [self.numberToEncodeTextField.text base32EncodedString];
    [self.numberToEncodeTextField resignFirstResponder];
}

- (IBAction)decodeButtonTouchUpInside
{
    self.decodedNumberTextView.text = [self.stringToDecodeTextView.text decodeBase32String];
    [self.stringToDecodeTextView resignFirstResponder];
}

- (void)viewDidUnload
{
    self.numberToEncodeTextField = nil;
    self.stringToDecodeTextView = nil;
    self.decodedNumberTextView = nil;
    
    [super viewDidUnload];
}

#pragma mark -
#pragma mark UITextViewDelegate Methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // If "Done" is pressed, run the decode logic, which should dismiss the
    // keyboard.
    if ([text isEqualToString:@"\n"])
    {
        [self decodeButtonTouchUpInside];
        
        return NO;
    }
    
    return YES;
}

@end
