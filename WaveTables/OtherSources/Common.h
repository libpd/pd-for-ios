/*
 *  Common.h
 *  SlidePad
 *
 *  Created by Rich E on 22/12/10.
 *  Copyright 2010 Richard T. Eakin. All rights reserved.
 *
 */

// debug macros from: http://www.cimgf.com/2010/05/02/my-current-prefix-pch-file/
// I modified DLog to use printf instead of NSLog

#ifdef DEBUG
#define DLog(nslog_string, ...)	printf("%s\t", __PRETTY_FUNCTION__); printf("%s", [[NSString stringWithFormat:nslog_string, ##__VA_ARGS__] UTF8String]); printf("\n");
#define ALog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__]
#else
#define DLog(...) do { } while (0)
#ifndef NS_BLOCK_ASSERTIONS
#define NS_BLOCK_ASSERTIONS
#endif
#define ALog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#endif

#define ZAssert(condition, ...) do { if (!(condition)) { ALog(__VA_ARGS__); }} while(0)