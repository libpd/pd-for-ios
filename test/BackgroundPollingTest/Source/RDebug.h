//
//  WDebug.h
//  Wombat
//
//  Created by Richard Eakin on 1/08/11.
//  Copyright 2011 Richard Eakin. All rights reserved.
//

//////////////////////////////////////////////////////////////////////
#ifdef R_DEBUG
//////////////////// Debug Mode //////////////////////////////////////

#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>

// Returns true if the current process is being debugged (either 
// running under the debugger or has a debugger attached post facto).
// from: Apple's Technical Q&A QA1361 - http://developer.apple.com/library/mac/#qa/qa1361/_index.html
static inline bool AmIBeingDebugged(void) {
    int                 junk;
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;
    info.kp_proc.p_flag = 0;
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);
    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}

// RBreak () - method to programmatically break at the line where it was called
// from: http://danwright.info/blog/author/dan/page/3/ and http://cocoawithlove.com/2008/03/break-into-debugger.html
#if __ppc64__ || __ppc__
#define RBreak() \
do { \
	if(AmIBeingDebugged()) \
	{ \
	__asm__("li r0, 20\nsc\nnop\nli r0, 37\nli r4, 2\nsc\nnop\n" \
	: : : "memory","r0","r3","r4" ); \
	} \
} while (0)
#elif __i386__ || __x86_64__
#define RBreak() \
do { \
	if(AmIBeingDebugged()) { \
	__asm__("int $3\n" : : ); \
	} \
} while (0)
#elif __arm__
#define RBreak() \
do { \
	if (AmIBeingDebugged()) { \
		__asm__("mov r0, #20\nmov ip, r0\nsvc 128\nmov r1, #37\nmov ip, r1\nmov r1, #2\nmov r2, #1\n svc 128\n" : : : "memory","ip","r0","r1","r2"); \
	} \
} while (0)
#else // unknown architecture
#define RBreak() \
do { \
	if (AmIBeingDebugged()) { \
		raise(SIGINT); \
	} \
} while (0)
#endif


// RStrackTrace - print the stacktrace back to the specified depth. if depth == 0, the entire stacktrace is printed
#define RStackTrace(depth) \
do { \
	printf("%s * CALL STACK *\n", __PRETTY_FUNCTION__); \
	int currentDepth = 0; \
	for (NSString* stackElement in [NSThread callStackSymbols]) { \
		if (!depth || currentDepth++ < depth) { \
			printf ("%s\n", [stackElement UTF8String]); \
		} else { \
			break; \
		} \
	} \
} while (0)


#define RLog(nslog_string, ...) \
do { \
	printf("%s\t", __PRETTY_FUNCTION__); \
	printf("%s\n", [[NSString stringWithFormat:nslog_string, ##__VA_ARGS__] UTF8String]); \
} while (0)

#define RAssert(check_value)	\
do { \
	if (!(check_value)) { \
		printf("%s * ASSERT FAILED *\t", __PRETTY_FUNCTION__); \
		printf("'%s'\n", #check_value); \
		RBreak(); \
	} \
} while (0)

#define RAssertM(check_value, nslog_string, ...) \
do { \
	if (!(check_value)) { \
		printf("%s * ASSERT FAILED *\t", __PRETTY_FUNCTION__); \
		printf("%s\n", [[NSString stringWithFormat:nslog_string, ##__VA_ARGS__] UTF8String]); \
		RBreak(); \
	} \
} while (0)

#define RWarnCheck(check_value, nslog_string, ...) \
do { \
	if (!(check_value)) { \
		{ printf("%s * WARNING *\t", __PRETTY_FUNCTION__); \
		printf("%s\n", [[NSString stringWithFormat:nslog_string, ##__VA_ARGS__] UTF8String]); \
	} \
} while (0)

#define RWarning(nslog_string, ...) \
do { \
	printf("%s * WARNING *\t", __PRETTY_FUNCTION__); \
	printf("%s\n", [[NSString stringWithFormat:nslog_string, ##__VA_ARGS__] UTF8String]); \
} while (0)

#define RError(nslog_string, ...) \
do { \
	printf("%s * ERROR *\t", __PRETTY_FUNCTION__); \
	printf("%s\n", [[NSString stringWithFormat:nslog_string, ##__VA_ARGS__] UTF8String]); \
} while (0)

//////////////////////////////////////////////////////////////////////
#else
//////////////////// Release Mode ////////////////////////////////////

#define RLog(...)
#define RAssert(check_value)
#define RAssertM(check_value, nslog_string, ...)
#define RWarnCheck(check_value, nslog_string, ...)
#define RWarning(nslog_string, ...)
#define RError(nslog_string, ...)
#define RBreak()

#define RStackTrace()

#endif
