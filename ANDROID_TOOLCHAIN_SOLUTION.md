# Solución para error de stripping de símbolos en Android

## Problema
Al construir el app bundle de Android, aparece el error:
```
Release app bundle failed to strip debug symbols from native libraries.
```

## Causa
Este error generalmente ocurre cuando el Android NDK (Native Development Kit) no está instalado o no está configurado correctamente en el Android SDK.

## Pasos para solucionar

### 1. Verificar instalación del NDK
- Abre Android Studio
- Ve a **Tools > SDK Manager**
- Selecciona la pestaña **SDK Tools**
- Busca **NDK (Side by side)** y **CMake**
- Marca ambas casillas y haz clic en **Apply**

### 2. Configurar rutas del NDK
Si ya tienes el NDK instalado pero el error persiste:
- Asegúrate de que la variable de entorno `ANDROID_NDK_HOME` apunte a tu NDK
- O especifica la ruta en `local.properties` en la carpeta `android/`:
  ```
  ndk.dir=/path/to/your/ndk
  ```

### 3. Actualizar Android SDK
- Asegúrate de tener las últimas versiones del SDK Platform y SDK Build-Tools
- En SDK Manager, actualiza a la versión más reciente

### 4. Limpiar y reconstruir
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build appbundle --release
```

### 5. Alternativa: Deshabilitar stripping (solo para debug)
Si necesitas una solución temporal, puedes deshabilitar el stripping en `android/app/build.gradle`:
```gradle
android {
    buildTypes {
        release {
            // Agregar esta línea
            stripDebugSymbols false
        }
    }
}
```
**Nota:** Esto aumentará el tamaño del APK/AAB. Solo úsalo para debugging.

## Verificación
Para verificar que el NDK está configurado correctamente:
```bash
flutter doctor -v
```
Busca la sección "Android toolchain" y verifica que el NDK esté listado.

## Referencias
- [Flutter Android build setup](https://docs.flutter.dev/deployment/android#build-the-app-for-release)
- [Android NDK documentation](https://developer.android.com/ndk)
