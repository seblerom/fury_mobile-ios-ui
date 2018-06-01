//
//  MLTextMask.h
//  MLUI
//
//  Created by Sebastian Leon romero on 31/05/2018.
//

#import <Foundation/Foundation.h>

@interface MLTextMask : NSObject

-(instancetype)initWithPattern:(NSString*)maskPattern andPatternRepresentation:(NSString*)maskRepresentation;
- (NSString*)applyMaskToTextfield:(NSString*)text;
-(int)offSetForCursorPosition;
-(void)setCurrentCursorPosition:(UITextField*)textField;
@end
