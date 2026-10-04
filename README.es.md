# Metin2 Account Aliases

[English](README.md) · [Deutsch](README.de.md) · **Español** · [Français](README.fr.md) ·
[Italiano](README.it.md) · [Português](README.pt.md) · [Română](README.ro.md) · [Türkçe](README.tr.md)

*Traducción de la [versión en inglés](README.md), actualizada el 4 de octubre de 2026. En caso de
diferencias, prevalece la versión en inglés.*

**Ponles nombres legibles a tus cuentas de Metin2 en el Gameforge Client y encuéntralas por su
nombre.**

Las cuentas de juego no se pueden renombrar nunca, y en el servidor Tigerghost el launcher incluso
les pone identificadores generados como `playerg123456789`. Con decenas de cuentas, cuatro por
página, encontrar la correcta es pura adivinanza. Este add-on gratuito te permite llamarlas
`main`, `buff` o `meley1`, directamente en la lista de cuentas del propio launcher.

https://github.com/user-attachments/assets/29c72fac-e7bd-4ce5-8bd2-43fdb9114b08

▶ **[Ver la demo en YouTube](https://www.youtube.com/watch?v=24Nq1rZX88w)** ·
⬇ **[Descargar la última versión](https://github.com/mt2-coder/mt2-account-aliases/releases/latest)** ·
gratuito y de código abierto ([MIT](LICENSE))

> Add-on no oficial: no está afiliado a Gameforge ni cuenta con su respaldo.

## Qué hace

En el launcher, **Configuración > Cuenta de juego**:

- **Ponles nombre a tus cuentas.** El lápiz junto al nombre de una cuenta le da un alias: Intro
  guarda, Esc cancela, un alias vacío lo elimina. Primero aparece el alias y, a su lado, el nombre
  real en letra pequeña y gris; un alias largo se recorta en pantalla y se muestra completo en la
  información emergente.
- **Encuéntralas por su nombre.** El propio cuadro de búsqueda del launcher (la lupa encima de la
  tabla) también encuentra las cuentas por su alias, y sus páginas siguen funcionando.
- **Guarda una copia de seguridad.** El botón **Manage**, abajo a la derecha, muestra todos tus
  alias como texto: cópialo para guardar una copia de seguridad, o pégalo y pulsa **Apply** para
  restaurarla o para llevar tus alias a otro PC.

El add-on y su instalador solo están en inglés: los botones se llaman **Manage**, **Copy** y
**Apply**, y los mensajes del instalador aparecen en inglés.

## ¿Es seguro?

El add-on se basa en una regla: no poner nunca en riesgo tu juego ni tu cuenta.

- **Nunca toca el juego.** Ni `metin2client.exe`, ni ningún archivo del juego, ni su antitrampas.
  Nada del add-on se ejecuta dentro del juego.
- **Es solo una capa sobre la ventana del launcher.** La interfaz del launcher es una página web
  guardada en un único archivo, `resources\frontend.pak`. El add-on añade un pequeño script a esa
  página y nada más: el programa del launcher, y la forma en que inicia el juego, siguen
  exactamente igual.
- **Tu cuenta queda intacta.** Los alias solo existen en tu PC: los nombres reales de tus cuentas
  nunca cambian, ni en tu PC ni en los servidores de Gameforge. El add-on no hace ninguna
  solicitud de red y nunca lee tu contraseña, tu sesión ni los datos de tu cuenta; solo lee los
  nombres de cuenta que ya están en pantalla.
- **Puedes deshacerlo en cualquier momento.** El instalador hace una copia de seguridad del
  archivo del launcher antes de modificarlo, y `Uninstall.cmd` restaura el original, byte a byte.
- **No hay nada oculto.** Ningún `.exe`: el add-on es un único archivo JavaScript que puedes leer,
  [`src/alias-addon.js`](src/alias-addon.js), y el instalador un único script de PowerShell,
  [`scripts/alias-addon.ps1`](scripts/alias-addon.ps1). Cada versión la compila GitHub a partir
  de este código público y viene con su suma SHA-256 y una
  [atestación de procedencia](https://github.com/mt2-coder/mt2-account-aliases/attestations)
  (provenance attestation).

El add-on es software libre bajo la licencia MIT, lo que significa que se ofrece sin garantía.

## Instalación

Necesitas Windows 10 u 11, el Gameforge Client y permisos de administrador.

1. Descarga `mt2-account-aliases-x.y.z.zip` de la
   [última versión](https://github.com/mt2-coder/mt2-account-aliases/releases/latest).
2. Haz clic derecho en el ZIP > **Propiedades** > marca **Desbloquear** > **Aceptar**, y después
   descomprímelo. Si no, Windows pide confirmación cada vez que ejecutas uno de sus archivos
   `.cmd`, porque no están firmados digitalmente.
3. Cierra tus clientes de Metin2 y después cierra el Gameforge Client por completo, incluido su
   icono en el área de notificación.
4. Haz doble clic en **`Install.cmd`** y pulsa **Sí** en el aviso de Windows (Control de cuentas
   de usuario): los archivos del launcher están en `Program Files` («Archivos de programa» en el
   Explorador), así que modificarlos requiere permisos de administrador.
5. Inicia el launcher y abre **Configuración > Cuenta de juego**.

El instalador encuentra el launcher esté donde esté instalado. Comprobado con Gameforge Client
2.8.5.1959 (interfaz 0.486.2).

El launcher guarda tus alias solo en este PC. Cualquier cosa que borre los datos del launcher los
borraría también, así que guarda una copia de seguridad con **Manage**.

## Desinstalación

Cierra el launcher y haz doble clic en **`Uninstall.cmd`**: vuelve el archivo original del
launcher, byte a byte. Tus alias siguen guardados en el launcher, así que al instalarlo de nuevo
vuelven.

## Cuando el launcher actualiza su interfaz

El launcher no puede actualizar una interfaz que el add-on ha modificado. Cuando anuncie una
actualización, o diga que no ha podido aplicar una:

1. ciérralo y haz doble clic en `Uninstall.cmd`;
2. inicia el launcher, deja que se actualice y ciérralo;
3. haz doble clic de nuevo en `Install.cmd`.

## Solución de problemas

- **¿Qué está instalado?** `Status.cmd` te lo dice, sin cambiar nada.
- **«Gameforge Client not found».** Abre un símbolo del sistema en la carpeta descomprimida
  (escribe `cmd` en la barra de direcciones del Explorador de archivos y pulsa Intro) e indica la
  ruta del `frontend.pak` del launcher:
  `Install.cmd -PakPath "D:\Juegos\GameforgeClient\resources\frontend.pak"`.
- **No aparecen lápices en la lista de cuentas.** Ejecuta `Install.cmd -Diagnostic` de la misma
  forma. Abajo a la izquierda de la ventana principal del launcher aparece una pequeña etiqueta
  que indica hasta dónde llegó el add-on:

  | Etiqueta | Significado |
  | --- | --- |
  | ninguna | el launcher no mostró la página modificada |
  | roja, `script did not run` | la página se muestra, pero el add-on nunca se ejecutó |
  | `active - no account on screen`, con la lista de cuentas abierta | el add-on se ejecuta, pero no encuentra ninguna cuenta |
  | `active - 4 account(s) on screen (2 windows)` | la lista de cuentas se encontró y se completó con los alias |
  | `... error (...): ...` | el mensaje indica qué falló |

  `Install.cmd` sin `-Diagnostic` quita la etiqueta.
- **El launcher cambió a otro idioma.** El add-on no tiene nada que ver: el icono del globo, arriba
  a la derecha del launcher, lo restablece.

---

## Para desarrolladores y los equipos de Gameforge

La parte técnica (cómo funciona el add-on, cómo podría integrarse la función en el propio
launcher, pruebas, versiones) solo está en inglés:
[For developers and Gameforge's teams](README.md#for-developers-and-gameforges-teams).

## Licencia

[MIT](LICENSE). Solo cubre este repositorio: el Gameforge Client y sus archivos, incluido
`frontend.pak`, siguen siendo de Gameforge.
