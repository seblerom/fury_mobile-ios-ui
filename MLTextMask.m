//
//  MLTextMask.m
//  MLUI
//
//  Created by Sebastian Leon romero on 31/05/2018.
//

#import "MLTextMask.h"

NSString* const kSpace = @" ";
NSString* const kZero = @"0";
NSString* const kEmpty = @"";

@interface MLTextMask()
@property (nonatomic, strong) NSString* maskPattern;
@property (nonatomic, strong) NSString* maskRepresentation;
@property (nonatomic, readwrite) NSMutableArray *mutablePattern;
@property (nonatomic, strong) NSString* finalText;
@property (nonatomic, strong) NSString* lastCharacterTyped;
@property (nonatomic, strong) NSString* rawText;
@property (nonatomic) int cursorPosition;
@end

@implementation MLTextMask

- (instancetype)initWithPattern:(NSString *)maskPattern andPatternRepresentation:(NSString *)maskRepresentation{
    _maskPattern = maskPattern;
    _maskRepresentation = maskRepresentation;
    [self patternToArray:_maskPattern];
    return self;
}

-(void)saveLastCharacterTyped:(NSString *)lastCharacterTyped{
    self.lastCharacterTyped = lastCharacterTyped;
}

- (NSString*)applyMaskToTextfield:(NSString*)text{
    
    _rawText = [self rawText:text];
    if (![_rawText isEqualToString:kEmpty]) {
        NSMutableArray * formatTextAsArray = [self stringToArrayWithPatternFormat:_rawText];
        _finalText = [[self arrayToString:formatTextAsArray] stringByReplacingOccurrencesOfString:_maskRepresentation withString:kSpace];

    }else{
        _finalText = @"";
    }
    
    return _finalText;
}

-(NSString*)rawText:(NSString*)text{
    NSMutableString * rawText = [[NSMutableString alloc]init];
    for (int index = 0; index < [text length]; index++) {
        NSString * character = [text substringWithRange:NSMakeRange(index, 1)];
        if ([self isNumber:character]){
            [rawText appendString:character];
        }
    }
    return rawText;
}


-(int)offSetForCursorPosition{
    int offset = 0;
    if ([_lastCharacterTyped isEqualToString:kEmpty]){
        offset = _cursorPosition;
//        if (_cursorPosition == 0) {
//            offset = [self nextCursorPosition];
//        }else{
//            offset = _cursorPosition;
//        }
    }else{
        offset = [self searchNextCharacterFromStartingPoint:_cursorPosition];
    }
    return offset;
}

-(int)searchNextCharacterFromStartingPoint:(int)startingPoint{
    int nextPosition = startingPoint;
    if (startingPoint < [_finalText length]) {
        NSString * character = [_finalText substringWithRange:NSMakeRange(startingPoint, 1)];
        if (![character isEqualToString:kSpace] && ![character isEqualToString:_maskRepresentation] && ![self isNumber:character]) {
            nextPosition += 1;
        }
    }else{
        nextPosition = (int)[_finalText length];
    }
    return nextPosition;
}

-(void)patternToArray:(NSString*)pattern{
    _mutablePattern = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i<= [_maskPattern length]-1; i++) {
        [_mutablePattern addObject:[_maskPattern substringWithRange:NSMakeRange(i, 1)]];
    }
}

-(NSString*)getCharacterFromRawText{
    NSString* character = @"";
    if ([_rawText length] > 0) {
        character = [_rawText substringWithRange:NSMakeRange(0, 1)];
    }
    return character;
}

-(void)deleteLastCharacterPoped{
    _rawText = [_rawText substringFromIndex:1];
}

-(NSMutableArray*)stringToArrayWithPatternFormat:(NSString*)text{
    NSMutableArray * mutablePatternCopy = _mutablePattern.mutableCopy;
    for (NSUInteger index = 0; index < [mutablePatternCopy count]; index++) {
        if ([[mutablePatternCopy objectAtIndex:index] isEqualToString:_maskRepresentation]){
            NSString* rawCharacter = [self getCharacterFromRawText];
            if (![rawCharacter isEqualToString:kEmpty]) {
                [mutablePatternCopy replaceObjectAtIndex:index withObject:rawCharacter];
                [self deleteLastCharacterPoped];
            }else{
                break;
            }
        }
    }
    return mutablePatternCopy;
}

-(void)setCurrentCursorPosition:(UITextField*)textField{
    UITextRange * selectedTextRange = textField.selectedTextRange;
    _cursorPosition = (int)[textField offsetFromPosition:textField.beginningOfDocument toPosition:selectedTextRange.start];
    
}

-(int)nextCursorPosition{
    int offset = 0;
    for (int index = 0; index < [self.finalText length]; index++) {
        NSString* character = [self.finalText substringWithRange:NSMakeRange(index, 1)];
        if ([self isNumber:character]) {
            offset = index + 1;
            break;
        }
    }
    return offset;
}

-(NSString*)arrayToString:(NSMutableArray*)array{
    
    NSMutableArray* mutableArray = array.mutableCopy;
    if ([mutableArray count] > [_maskPattern length]){
        [mutableArray removeLastObject];
    }
    
    NSMutableString* returnText = [[NSMutableString alloc] initWithString:@""];
    for (NSString* character in mutableArray) {
        [returnText appendString:character];
    }
    return returnText;
}

-(BOOL)isNumber:(NSString*)text{
    if ([text intValue] || [text isEqualToString:kZero]){
        return true;
    }
    return false;
}


@end
