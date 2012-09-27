#ifdef R_DEBUG
	#define RLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#else
	#define RLog(...) do { } while (0)
#endif
