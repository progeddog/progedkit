//
// SAXParser.m
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

#import "SAXParser.h"

#import "Logging.h"

static NSUInteger const kDrainFrequency = 50;
static NSUInteger const kFetchTimeout = 30; // s

static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, 
                            const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, 
                            int nb_attributes, int nb_defaulted, const xmlChar **attributes);
static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, 
                          const xmlChar *URI);
static void	charactersFoundSAX(void * ctx, const xmlChar * ch, int len);
static void errorEncounteredSAX(void * ctx, const char * msg, ...);

static xmlSAXHandler rssParserHandlerStruct;

@interface SAXParser()
@property (nonatomic,retain) NSURLConnection *connection;
@property (nonatomic,assign) BOOL done;
@property (nonatomic,assign) BOOL running;
@property (nonatomic,assign) BOOL readingString;
@property (nonatomic,retain) NSMutableString *stringBuffer;
@property (nonatomic,assign) NSUInteger drainCounter;

@property (nonatomic,assign) xmlParserCtxtPtr context;

// extend
@property (nonatomic,retain) NSURL *URL;

- (void) performParsing;
- (NSString *) captureString:(BOOL)reading;
@end

@implementation SAXParser


- (id) initWithURL:(NSURL *)anURL {
	self = [super init];
	if (self) {
        self.URL = anURL;
        
        self.stringBuffer = [NSMutableString string];
	}
	return self;
}

- (void) parse {
	if ([delegate respondsToSelector:@selector(parserDidStarted:)]) {
		[delegate parserDidStarted:self];
	}
	
	[self performSelectorInBackground:@selector(performParsing) withObject:nil];
}

- (void) abort {
    [self.connection cancel];
    self.done = YES;
}

- (void) initParsing {
    DLog(@"SAX init parsing");
    self.drainCounter = 0;
    self.readingString = NO;
    [self.stringBuffer setString:@""];
    
    if ([self.handler respondsToSelector:@selector(initParsing:)])
        [self.handler initParsing:self];
}

- (void) finishParsing {
    DLog(@"SAX finish parsing");
    if ([self.handler respondsToSelector:@selector(finishParsing:)])
        [self.handler finishParsing:self];
}

- (void) performParsing {
    if (!self.running) {
        NSAutoreleasePool *parsePool = [[NSAutoreleasePool alloc] init];
        
        self.running = YES;
        [self initParsing];
        
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        NSURLRequest *request = 
        [NSURLRequest requestWithURL:self.URL 
                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData 
                     timeoutInterval:kFetchTimeout];
        self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] 
                           autorelease];
        
        if (self.connection != nil) {
            self.context = xmlCreatePushParserCtxt(&rssParserHandlerStruct, self, NULL, 0, NULL);
            self.done = NO;
            do {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode 
                                         beforeDate:[NSDate distantFuture]];
                if (self.drainCounter > kDrainFrequency) {
                    [parsePool drain];
                    parsePool = [[NSAutoreleasePool alloc] init];
                    self.drainCounter = 0;
                }
            } while (!self.done);
            xmlFreeParserCtxt(self.context), self.context = nil;
        }
        else {
            @throw [[[SAXParserException alloc] initWithName:@"SAXError" 
                                                      reason:@"Can't create connection" 
                                                    userInfo:nil] autorelease];
        }
        
        self.connection = nil;
        
        [self finishParsing];
        [self.delegate performSelectorOnMainThread:@selector(parserDidFinished:) 
                                        withObject:self
                                     waitUntilDone:NO];
        self.running = NO;
        [parsePool drain];
    }
    else {
        @throw [[[SAXParserException alloc] initWithName:@"SAXError" 
                                                  reason:@"Parser is already running" 
                                                userInfo:nil] autorelease];
    }
}

- (NSString *) captureString:(BOOL)reading {
	if (!reading && self.readingString) {
        NSString *string = [[self.stringBuffer copy] autorelease];
        [self.stringBuffer setString:@""];
        
        self.readingString = reading;
        return string;
	}
    
    self.readingString = reading;
    return nil;
}

#pragma mark -
#pragma mark NSURLConnection

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection 
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	ALog("Connection error: %@ in %@", error, self.URL);
	self.done = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (!self.done)
        xmlParseChunk(self.context, (const char *)[data bytes], [data length], 0);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (!self.done) {
        // Signal the context that parsing is complete by passing "1" as the last parameter.
        xmlParseChunk(self.context, NULL, 0, 1);
        self.done = YES; 
    }
}

#pragma mark - 
#pragma mark SAX

- (void) saxBeginElement:(const char *)name 
          withAttributes:(const char **)attributes
         attributesCount:(int)count {
    if (!self.done && [self.handler 
                       respondsToSelector:@selector(parser:beginElement:withAttributes:)]) {
        NSString *elementName = [NSString stringWithUTF8String:name];
        NSMutableArray *attributesArray = [NSMutableArray arrayWithCapacity:count];
        for (int i=0; i<count; i++) {
            if (attributes[i])
                [attributesArray addObject:[NSString stringWithUTF8String:attributes[i]]];
        }
        
        BOOL captureNeeded = [self.handler parser:self beginElement:elementName
                                   withAttributes:[[attributesArray copy] autorelease]];
        if (captureNeeded) {
            [self captureString:YES];
        }
    }
}

- (void) saxEndElement:(const char *)name {
    if (!self.done && [self.handler respondsToSelector:@selector(parser:endElement:withContent:)]) {
        NSString *elementName = [NSString stringWithUTF8String:name];
        [self.handler parser:self endElement:elementName withContent:[self captureString:NO]];
    }
}

- (void) saxCharactersFound:(NSString *)string {
	if (!self.done && self.readingString)
		[self.stringBuffer appendString:string];
}

- (void) saxError:(const char *)msg {
    if (!self.done) {
        ALog(@"Parse error: %@, %@", [[[NSString alloc] initWithBytes:msg 
                                                               length:strlen(msg) 
                                                             encoding:NSUTF8StringEncoding] 
                                      autorelease],
             self.URL);
        [self abort];
    }
}

#pragma mark -
#pragma mark Protected

- (void) increaseDrainCounter {
    self.drainCounter ++;
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
    self.URL = nil;
    
    self.connection = nil;
    self.stringBuffer = nil;
    [super dealloc];
}

#pragma mark -
@synthesize delegate;
@synthesize handler;
@synthesize URL;

@synthesize done;
@synthesize running;
@synthesize connection;
@synthesize stringBuffer;
@synthesize readingString;
@synthesize context;
@synthesize drainCounter;
@end

@implementation SAXParserException
@end

/******************************************************** SAX Parser */

static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, 
                            const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, 
                            int nb_attributes, int nb_defaulted, const xmlChar **attributes) {
	
    SAXParser *parser = (SAXParser *)ctx;
    [parser saxBeginElement:(const char *)localname 
             withAttributes:(const char **)attributes 
            attributesCount:nb_attributes];
}

static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, 
                          const xmlChar *URI) {    
    SAXParser *parser = (SAXParser *)ctx;
    [parser saxEndElement:(const char *)localname];
}

static void	charactersFoundSAX(void *ctx, const xmlChar *ch, int len) {
    SAXParser *parser = (SAXParser *)ctx;
	[parser saxCharactersFound:[[[NSString alloc] initWithBytes:(const char *)ch 
														 length:len 
													   encoding:NSUTF8StringEncoding] autorelease]];
}

static void errorEncounteredSAX(void *ctx, const char *msg, ...) {
    SAXParser *parser = (SAXParser *)ctx;
	[parser saxError:msg];
}

static xmlSAXHandler rssParserHandlerStruct = {
    NULL,                       /* internalSubset */
    NULL,                       /* isStandalone   */
    NULL,                       /* hasInternalSubset */
    NULL,                       /* hasExternalSubset */
    NULL,                       /* resolveEntity */
    NULL,                       /* getEntity */
    NULL,                       /* entityDecl */
    NULL,                       /* notationDecl */
    NULL,                       /* attributeDecl */
    NULL,                       /* elementDecl */
    NULL,                       /* unparsedEntityDecl */
    NULL,                       /* setDocumentLocator */
    NULL,                       /* startDocument */
    NULL,                       /* endDocument */
    NULL,                       /* startElement*/
    NULL,                       /* endElement */
    NULL,                       /* reference */
    charactersFoundSAX,         /* characters */
    NULL,                       /* ignorableWhitespace */
    NULL,                       /* processingInstruction */
    NULL,                       /* comment */
    NULL,                       /* warning */
    errorEncounteredSAX,        /* error */
    NULL,                       /* fatalError //: unused error() get all the errors */
    NULL,                       /* getParameterEntity */
    NULL,                       /* cdataBlock */
    NULL,                       /* externalSubset */
    XML_SAX2_MAGIC,             //
    NULL,
    startElementSAX,            /* startElementNs */
    endElementSAX,              /* endElementNs */
    NULL,                       /* serror */
};

