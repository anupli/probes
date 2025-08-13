#include <jni.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <sys/sdt.h>

/* JNI Functions */
JNIEXPORT void JNICALL Java_probe_USDTProbe_begin_1native
  (JNIEnv *env, jobject o, jstring benchmark, jint iteration, jboolean warmup, jlong thread_id) {
    /* (void*, int, bool, long) */
    STAP_PROBE4(DaCapo, begin, benchmark, iteration, warmup, thread_id);
}

JNIEXPORT void JNICALL Java_probe_USDTProbe_end_1native
  (JNIEnv *env, jobject o, jstring benchmark, jint iteration, jboolean warmup, jlong thread_id) {
    // jstring is an opaque type
    /* (void*, int, bool, long) */
    STAP_PROBE4(DaCapo, end, benchmark, iteration, warmup, thread_id);
}
