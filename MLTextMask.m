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
@property (nonatomic, readwrite) NSMutableArray *textToShow;
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

- (NSString*)applyMaskToTextfield:(NSString*)text{
    
    _rawText = [self rawText:text];
    NSMutableArray * formatTextAsArray = [self stringToArrayWithPatternFormat:_rawText];
    _finalText = [[self arrayToString:formatTextAsArray] stringByReplacingOccurrencesOfString:_maskRepresentation withString:kSpace];
//    if ([textfield.text isEqualToString:kEmpty] && string != kEmpty) {
//        NSMutableArray * formatTextAsArray = [self stringToArrayWithPatternFormat:[textfield.text stringByReplacingCharactersInRange:range withString:string]];
//        _finalText = [[self arrayToString:formatTextAsArray] stringByReplacingOccurrencesOfString:_maskRepresentation withString:kSpace];
//    }else{
//        if ([self isNumber:[textfield.text substringWithRange:range]] || [[textfield.text substringWithRange:range] isEqualToString:kSpace]) {
//            NSMutableArray * formatTextAsArray = [self stringToArrayWithPatternFormat:[textfield.text stringByReplacingCharactersInRange:range withString:string]];
//            _finalText = [[self arrayToString:formatTextAsArray] stringByReplacingOccurrencesOfString:_maskRepresentation withString:kSpace];
//        }
//    }
    
    
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

-(BOOL)shouldContinueFormatting:(NSString*)text{
    
    return NO;
}

-(int)offSetForCursorPosition{
    int offset = 0;
    if ([_lastCharacterTyped isEqualToString:kEmpty]){
        offset = [self searchPreviousCharacterFromStartingPoint:_cursorPosition];
    }else{
        offset = [self searchNextCharacterFromStartingPoint:_cursorPosition];
    }
    return offset;
}

-(int)searchNextCharacterFromStartingPoint:(int)startingPoint{
    int nextPosition = startingPoint;
    for (int index = startingPoint; index < [_finalText length]; index++) {
        NSString * character = [_finalText substringWithRange:NSMakeRange(index, 1)];
        if ([character isEqualToString:kSpace]) {
            break;
        }else{
            nextPosition += 1;
        }
    }
    return nextPosition;
}

-(int)searchPreviousCharacterFromStartingPoint:(int)startingPoint{
    int nextPosition = startingPoint;
    for (int index = startingPoint; index > 0; index--) {
        NSString * character = [_finalText substringWithRange:NSMakeRange(index, 1)];
        if ([character isEqualToString:kSpace] || [self isNumber:character]) {
            break;
        }else{
            nextPosition -= 1;
        }
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
        if ([self isNumber:[mutablePatternCopy objectAtIndex:index]] || [[mutablePatternCopy objectAtIndex:index]isEqualToString:_maskRepresentation] ) {
            NSString* character = [self getCharacterFromRawText];
            if ([self isNumber:character]) {
                [mutablePatternCopy replaceObjectAtIndex:index withObject:character];
                [self deleteLastCharacterPoped];
            }
        }
    }
    return mutablePatternCopy;
}

-(void)setCurrentCursorPosition:(UITextField*)textField{
    UITextRange * selectedTextRange = textField.selectedTextRange;
    _cursorPosition = (int)[textField offsetFromPosition:textField.beginningOfDocument toPosition:selectedTextRange.start];
    
}

-(int)nextCursorPositionFrom:(int)currentOffset{
    int offset = currentOffset;
//    if (![self.lastCharacterTyped isEqualToString:kEmpty]){
//        if ([self.textField.text length] > offset){
//            NSString * character = [self.textField.text substringWithRange:NSMakeRange(offset, 1)];
//            if (![self isNumber:character] && ![character isEqualToString:kSpace]) {
//                offset += 1;
//            }
//            offset += 1;
//        }
//    }else{
//        offset = [self lastNumericPositionFromText:self.textField.text];
//    }
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

-(NSString*)maskCheckWith:(UITextField *)textfield andLastCharacterTyped:(NSString*)lastCharacterTyped{
    
    self.textToShow = [[self stringToArrayWithPatternFormat:textfield.text] mutableCopy];
    if (![lastCharacterTyped isEqualToString:kEmpty]){
        if ([self.textToShow count] > self.cursorPosition){
            NSString * character = [self.textToShow objectAtIndex:self.cursorPosition];
            if([character isEqualToString:_maskRepresentation] || [self isNumber:character]){
                [self.textToShow insertObject:lastCharacterTyped atIndex:self.cursorPosition];
            }else{
                [self.textToShow insertObject:lastCharacterTyped atIndex:self.cursorPosition + 1];
            }
            self.textToShow = [self stringToArrayWithPatternFormat:[self arrayToString:self.textToShow]];
        }
    }else{
        int newCursorPositionAfterDeletion = self.cursorPosition - 1;
        if (newCursorPositionAfterDeletion <= 0){
            self.textToShow = [[NSMutableArray alloc]init];
            [self.textToShow addObject:@""];
        }else{
            if ([self.textToShow count] > self.cursorPosition - 1){
                NSString * character = [self.textToShow objectAtIndex:self.cursorPosition - 1];
                if (![self isNumber:character]){
                    if ([self firstNumericPositionFromText:textfield.text] > 0){
                        [self.textToShow replaceObjectAtIndex:self.cursorPosition - 2 withObject:_maskRepresentation];
                        [self moveObjects:self.textToShow];
                        return [[self arrayToString:self.textToShow]stringByReplacingOccurrencesOfString:_maskRepresentation withString:kSpace];
                    }
                    return @"";
                }
                [self.textToShow replaceObjectAtIndex:self.cursorPosition - 1 withObject:_maskRepresentation];
                [self moveObjects:self.textToShow];
                self.textToShow = [self stringToArrayWithPatternFormat:[self arrayToString:self.textToShow]];
            }
        }
    }
    return [[self arrayToString:self.textToShow]stringByReplacingOccurrencesOfString:_maskRepresentation withString:kSpace];
}

-(void)moveObjects:(NSMutableArray*)mutableText{
    NSMutableArray* mu = mutableText.mutableCopy;
    for (int index = 0; index < [mu count]; index++) {
        int posCharacter = [self getPositionFromArray:mu withSearchCharacter:_maskRepresentation];
        int posNumber = [self getNumericPositionFrom:mu withStartingPoint:posCharacter];
        if (posNumber > posCharacter){
            [mu exchangeObjectAtIndex:posCharacter withObjectAtIndex:posNumber];
        }else{
            break;
        }
    }
    self.textToShow = mu;
}

-(int)getPositionFromArray:(NSMutableArray*)array withSearchCharacter:(NSString*)searchCharacter{
    int position = 0;
    for (int index = 0 ; index < [array count]; index++) {
        position = index;
        if ([[array objectAtIndex:index] isEqualToString:searchCharacter]) {
            break;
        }
    }
    return position;
}

-(int)getNumericPositionFrom:(NSMutableArray*)array withStartingPoint:(int)startingPoint{
    int position = 0;
    for (int index = startingPoint; index < [array count]; index++) {
        position = index;
        if ([self isNumber:[array objectAtIndex:index]]) {
            break;
        }
    }
    return position;
}

-(int)firstNumericPositionFromText:(NSString*)text{
    int position = 0;
    for (NSUInteger index = 0; index < [text length]; index++) {
        if ([[text substringWithRange:NSMakeRange(index, 1)] isEqualToString:kSpace]){
            break;
        }
        position = (int)index;
    }
    return position;
}

-(int)lastNumericPositionFromText:(NSString*)text{
    int position = 0;
    for (NSUInteger index = 0; index < [text length]; index++) {
        position = (int)index;
        if ([[text substringWithRange:NSMakeRange(index, 1)]isEqualToString:kSpace]){
            break;
        }
    }
    return position;
}


-(BOOL)isNumber:(NSString*)text{
    if ([text intValue] || [text isEqualToString:kZero]){
        return true;
    }
    return false;
}


@end
