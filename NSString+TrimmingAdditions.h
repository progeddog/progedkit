//
// NSString+TrimmingAdditions.h
//
// See
// http://stackoverflow.com/questions/5689288/how-to-remove-whitespace-from-right-end-of-nsstring
// Authors: Regexident, MattDiPasquale, Max
//

#import <Foundation/Foundation.h>

@interface NSString (TrimmingAdditions)
- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet;
@end
