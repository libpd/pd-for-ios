
// debug macros from: http://www.cimgf.com/2010/05/02/my-current-prefix-pch-file/
#ifdef R_DEBUG
#define RLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define RLog(...) do { } while (0)
#endif
