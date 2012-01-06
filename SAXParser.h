//
// SAXParser.h
// Objective C adapter for SAX mode of libxml.
//
// Copyright (C) 2012 Yurii Pavlovskii <progdogdev@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import <libxml/tree.h>

@class SAXParser;

@protocol ParserDelegate <NSObject>
@optional
- (void) parserDidStarted:(SAXParser *)parser;
- (void) parserDidFinished:(SAXParser *)parser;
@end

@protocol ParserHandler <NSObject>
@optional
- (void) initParsing:(SAXParser *)parser;
- (void) finishParsing:(SAXParser *)parser;
- (BOOL) parser:(SAXParser *)parser beginElement:(NSString *)element 
  withAttributes:(NSArray *)attributes;
- (void) parser:(SAXParser *)parser endElement:(NSString *)element withContent:(NSString *)content;
@end

@interface SAXParser : NSObject {
    NSObject<ParserDelegate> *delegate;
    NSObject<ParserHandler> *handler;
    NSURL *URL;
    
    BOOL done;
    BOOL running;
    NSURLConnection *connection;
    NSMutableString *stringBuffer;
    BOOL readingString;
    xmlParserCtxtPtr context;
    NSUInteger drainCounter;
}

@property (nonatomic,assign) NSObject<ParserDelegate> *delegate;
@property (nonatomic,assign) NSObject<ParserHandler> *handler;
@property (nonatomic,retain,readonly) NSURL *URL;

- (id) initWithURL:(NSURL *)feedURL;
- (void) parse;
- (void) abort;

@end

@interface SAXParser(Protected)
- (void) increaseDrainCounter;

- (void) initParsing;
- (void) finishParsing;
@end

@interface SAXParserException : NSException
@end
