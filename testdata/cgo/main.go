package main

// typedef int (*intFunc) ();
//
// int
// bridge_int_func(intFunc f)
// {
//		return f();
// }
//
// int fortytwo()
// {
//	    return 42;
// }
import "C"
import "log"

func main() {
	f := C.intFunc(C.fortytwo)
	if want, got := 42, int(C.bridge_int_func(f)); want != got {
		log.Fatal("want %d, got %d", want, got)
	}
}
