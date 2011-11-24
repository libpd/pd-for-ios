#if defined(R_DEBUG)
#define RLog(nslog_string, ...)	printf("%s\t", __PRETTY_FUNCTION__); printf("%s", [[NSString stringWithFormat:nslog_string, ##__VA_ARGS__] UTF8String]); printf("\n");
#else
#define RLog(nslog_string, ...)		
#endif
