# Stripe SDK
-keep class com.stripe.android.** { *; }
-keep class com.reactnativestripesdk.** { *; }
-keep interface com.reactnativestripesdk.** { *; }
-keep class com.stripe.android.pushprovisioning.** { *; }

# Keep all Stripe model classes
-keep class com.stripe.android.model.** { *; }

# Keep Stripe PaymentSheet classes
-keep class com.stripe.android.paymentsheet.** { *; }

# Keep Stripe Link classes
-keep class com.stripe.android.link.** { *; }

# Keep Stripe Financial Connections classes
-keep class com.stripe.android.financialconnections.** { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep serialization
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses

# Keep all model classes
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}
