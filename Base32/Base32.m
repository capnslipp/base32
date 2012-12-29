/*
 * Base32.m
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

/*
 * Release History
 *
 * Version 1.0 (12/29/2012)
 * ------------------------
 * - Initial release.
 */

#import "Base32.h"


@implementation NSString (Base32Crockford)

- (NSString *)base32EncodedString
{
    return [Base32 encode:self];
}

- (NSString *)decodeBase32String
{
    return [Base32 decode:self];
}

@end

@implementation Base32

+ (NSString *)encode:(NSString *)numberToEncode
{
    // Nothing to do
    if ([numberToEncode length] <= 0)
    {
        return @"";
    }

    long long nTemp = [numberToEncode longLongValue];

    // Number isn't a valid decimal text representation of a number.
    if (nTemp == 0)
    {
        return @"";
    }

    // If the value overflows, don't do anything and just return an empty
    // string.
    if (nTemp == LLONG_MAX || nTemp == LLONG_MIN)
    {
        return @"";
    }
    
    // Define and populate the encoding characters array
    char kEncodeCharsArray[] =
    {
        '0', '1', '2', '3', '4',
        '5', '6', '7', '8', '9',
        'A', 'B', 'C', 'D', 'E',
        'F', 'G', 'H', 'J', 'K',
        'M', 'N', 'P', 'Q', 'R',
        'S', 'T', 'V', 'W', 'X',
        'Y', 'Z', '?'
    };
    
    __block char *kEncodeChars = kEncodeCharsArray;

    // Get the two's complement representation of the input
    NSString *binaryString = [self binaryStringFromNumber:@(nTemp)];
    
    // Revers the string
    NSString *reversedString = [self reverseString:binaryString];
    
    // Create the regular expression pattern that we'll use to split the input.
    // We will process 5 digits at a time.
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@".{1,5}"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    // Use the correct prefix depending on whether using ARC.
#if __has_feature(objc_arc)
    __weak
#else
    __block
#endif
    NSMutableString *str = [NSMutableString string];
    
    // Process each group of five digits
    [regex enumerateMatchesInString:reversedString
                            options:NSMatchingReportProgress
                              range:NSMakeRange(0, [reversedString length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
     {
         NSRange matchRange = [result range];
         
         NSString *s = [reversedString substringWithRange:matchRange];
         NSString *r = [self reverseString:s];
         long long index = [self integerFromBinaryString:r];
         
         [str appendFormat:@"%c", kEncodeChars[index]];
     }];
    
    return [self reverseString:str];
}

+ (NSString *)decode:(NSString *)base32String
{
    // Define all the mappings
    NSDictionary *kDecodeMap = @{@"0": @0,  @"1": @1,  @"2": @2,  @"3": @3,
                                 @"4": @4,  @"5": @5,  @"6": @6,  @"7": @7,
                                 @"8": @8,  @"9": @9,  @"A": @10, @"B": @11,
                                 @"C": @12, @"D": @13, @"E": @14, @"F": @15,
                                 @"G": @16, @"H": @17, @"J": @18, @"K": @19,
                                 @"M": @20, @"N": @21, @"P": @22, @"Q": @23,
                                 @"R": @24, @"S": @25, @"T": @26, @"V": @27,
                                 @"W": @28, @"X": @29, @"Y": @30, @"Z": @31,
                                 @"?": @32, @"I": @1,  @"L": @1,  @"O": @0};
    
    // Don't do anything if the input string is of length zero.
    if ([base32String length] == 0)
    {
        return @"";
    }
    
    NSString *number = [NSString stringWithString:base32String];
    
    // Remove any existing dashes and convert all the letters to uppercase
    number = [number stringByReplacingOccurrencesOfString:@"-" withString:@""];
    number = [number uppercaseString];
    
    // If we end up with nothing, don't do anything.
    if ([number length] == 0)
    {
        return @"";
    }
    
    // Dynamically allocated items, like arrays, cannot be used in blocks, so
    // define a pointer that can be used to insert numbers into the array.
    int charsArray[[number length]];
    int *chars = charsArray;
    
    // Keep a record of how many items we put in the charsArray
    __block int charCount = 0;
    
    // Use the Objective-C fast enumeration methods to traverse the input
    // string. This is faster than manually going over every character in a for
    // loop, for example.
    NSStringEnumerationOptions enumerationOptions = NSStringEnumerationByComposedCharacterSequences;
    
    [number enumerateSubstringsInRange:NSMakeRange(0, [number length])
                               options:enumerationOptions
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
    {
        // Lookup the character in our table and add get the corresponding
        // number. Also increment the count.
        chars[charCount] = [kDecodeMap[substring] intValue];
        charCount++;
    }];
    
    NSString *resultString = @"";
    
    // Protect against very large numbers.
    if ([number length] <= 10)
    {
        unsigned long long result = 0;
        
        for (int i = 0; i < charCount; i++)
        {
            //NSLog(@"%i", charsArray[i]);
            result = (result << 5) + charsArray[i];
        }
        
        resultString = [NSString stringWithFormat:@"%llu", result];
    }
    else
    {
        // Just return an empty string if the resulting number is too large for
        // primitive types.
        resultString = @"";
    }

    return resultString;
}

+ (NSString *)reverseString:(NSString *)stringToReverse
{
    // Use the fast enumeration methods to reverse the string. This is much
    // faster than stepping over every character and constructing a string with those characters.
    NSMutableString *reversedString = [[NSMutableString alloc] init];
    NSStringEnumerationOptions enumerationOptions = (NSStringEnumerationReverse | NSStringEnumerationByComposedCharacterSequences);
    
    [stringToReverse enumerateSubstringsInRange:NSMakeRange(0, [stringToReverse length])
                                        options:enumerationOptions
                                     usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
     {
         [reversedString appendString:substring];
     }];
    
    // No need to autorelease if using ARC.
#if __has_feature(objc_arc)
    return reversedString;
#else
    return [reversedString autorelease];
#endif
}

+ (long long)integerFromBinaryString:(NSString *)binaryString
{
    const char *utf8String = [binaryString UTF8String];
    char *endPtr = NULL;
    long long foo = strtoull(utf8String, &endPtr, 2);
    
    if (endPtr != utf8String + strlen(utf8String))
    {
        // String wasn't entirely a binary number
        return -1;
    }
    
    if (errno == ERANGE && (foo == LLONG_MAX || foo == LLONG_MIN))
    {
        // Number was too big or too small
        return -1;
    }
    
    if (errno == EINVAL && foo == 0)
    {
        // No conversion could be performed
        return -1;
    }
    
    return foo;
}

+ (NSString *)binaryStringFromNumber:(NSNumber *)number
{
    unsigned long long localNumber = [number unsignedLongLongValue];
    unsigned long long num = localNumber;
    
    // Figure out the maximum power of 2 needed
    int maxPowerNeeded = log(num) / log(2) + 1;
    
    // Start with empty string
    NSMutableString *result = [NSMutableString stringWithCapacity:maxPowerNeeded];
    
    // Iterate down through the powers of 2
    for (int i = maxPowerNeeded; i >= 0; i--)
    {
        unsigned long long currentPower = powl(2, i);
        
        // If the number is greater than current power of 2
        if (currentPower <= num)
        {
            // Subtract the power of 2
            num -= currentPower;
            
            // Append "1" to result string
            [result appendString:@"1"];
        }
        else
        {
            // Otherwise append "0" only if we have any preceding digits
            if ([result length] > 0)
            {
                [result appendString:@"0"];
            }
        }
    }
    
    return result;
}

@end
