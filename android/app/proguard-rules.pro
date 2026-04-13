# Stripe SDK - Keep all classes
-keep class com.stripe.android.** { *; }
-keep interface com.stripe.android.** { *; }
-keep enum com.stripe.android.** { *; }

# Stripe React Native SDK
-keep class com.reactnativestripesdk.** { *; }
-keep interface com.reactnativestripesdk.** { *; }
-keep enum com.reactnativestripesdk.** { *; }

# Stripe Push Provisioning (specific classes that are missing)
-keep class com.stripe.android.pushprovisioning.** { *; }
-keep class com.stripe.android.pushprovisioning.PushProvisioningActivity { *; }
-keep class com.stripe.android.pushprovisioning.PushProvisioningActivity$* { *; }
-keep class com.stripe.android.pushprovisioning.PushProvisioningActivityStarter { *; }
-keep class com.stripe.android.pushprovisioning.PushProvisioningActivityStarter$Args { *; }
-keep class com.stripe.android.pushprovisioning.PushProvisioningActivityStarter$Error { *; }
-keep class com.stripe.android.pushprovisioning.PushProvisioningEphemeralKeyProvider { *; }
-keep class com.stripe.android.pushprovisioning.EphemeralKeyUpdateListener { *; }

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
-keepattributes EnclosingMethod

# Keep all model classes
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Don't warn about missing classes
-dontwarn com.stripe.android.**
-dontwarn com.reactnativestripesdk.**
