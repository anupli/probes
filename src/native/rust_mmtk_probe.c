#include <jni.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>

// Global states
static bool probe_initialized = false;
static bool using_mmtk = false;
static void (*harness_begin)(jlong) = NULL;
static void (*harness_end)(jlong) = NULL;

// Find symbols if not yet initialized.
// Don't call this function from two threads simultaneously.  DaCapo won't.
static bool ensure_initialzed() {
  if (!probe_initialized) {
    void* handle = dlopen(NULL, RTLD_LAZY);
    if (handle == NULL) {
      perror("Failed to dlopen this process.");
      exit(1);
    }

    bool (*openjdk_is_gc_initialized)(void) = dlsym(handle, "openjdk_is_gc_initialized");
    if (openjdk_is_gc_initialized == NULL) {
      // This OpenJDK binary is linked with the MMTK binding.
      // Maybe the user invoked DaCapo with probes on a stock OpenJDK binary.
      // Do nothing here.
    } else {
      // The current process is linked against MMTk.
      // Let's see if MMTk is enabled (i.e. by -XX:+UseThirdPartyHeap).
      using_mmtk = openjdk_is_gc_initialized();

      // Regardless whether MMTk is enabled,
      // as long as we are linked against the MMTk binding,
      // we should be able to resolve the following symbols.
      harness_begin = dlsym(handle, "harness_begin");
      if (harness_begin == NULL) {
        perror("Using MMTk, but cannot resolve symbol 'harness_begin'");
        exit(2);
      }

      harness_end = dlsym(handle, "harness_end");
      if (harness_end == NULL) {
        perror("Using MMTk, but cannot resolve symbol 'harness_end'");
        exit(3);
      }
    }

    probe_initialized = true;
  }

  // Return whether the callbacks should call the harness_{begin,end} functions.
  return using_mmtk;
}

/* JNI Functions */

JNIEXPORT void JNICALL Java_probe_RustMMTkProbe_begin_1native
  (JNIEnv *env, jobject o, jstring benchmark, jint iteration, jboolean warmup, jlong thread_id) {
  if (ensure_initialzed()) {
    (*harness_begin)(thread_id);
  }
}

JNIEXPORT void JNICALL Java_probe_RustMMTkProbe_end_1native
  (JNIEnv *env, jobject o, jstring benchmark, jint iteration, jboolean warmup, jlong thread_id) {
  if (ensure_initialzed()) {
    (*harness_end)(thread_id);
  }
}

JNIEXPORT void JNICALL Java_probe_RustMMTk32Probe_begin_1native
  (JNIEnv *env, jobject o, jstring benchmark, jint iteration, jboolean warmup, jlong thread_id) {
  if (ensure_initialzed()) {
    (*harness_begin)(thread_id);
  }
}

JNIEXPORT void JNICALL Java_probe_RustMMTk32Probe_end_1native
  (JNIEnv *env, jobject o, jstring benchmark, jint iteration, jboolean warmup, jlong thread_id) {
  if (ensure_initialzed()) {
    (*harness_end)(thread_id);
  }
}