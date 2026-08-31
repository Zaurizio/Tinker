package Tinker.demo.util;

import java.util.Base64;

public final class FotoPerfilUtil {

    private static final byte[] ASSINATURA_JPEG = { (byte) 0xFF, (byte) 0xD8, (byte) 0xFF };
    private static final byte[] ASSINATURA_PNG =
            { (byte) 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A };

    private FotoPerfilUtil() {
    }

    public static String paraDataUri(byte[] foto) {
        if (foto == null || foto.length == 0) {
            return null;
        }
        String tipo = tipoImagem(foto);
        if (tipo == null) {
            return null;
        }
        return "data:" + tipo + ";base64," + Base64.getEncoder().encodeToString(foto);
    }

    public static String tipoImagem(byte[] bytes) {
        if (comecaCom(bytes, ASSINATURA_JPEG)) {
            return "image/jpeg";
        }
        if (comecaCom(bytes, ASSINATURA_PNG)) {
            return "image/png";
        }
        return null;
    }

    private static boolean comecaCom(byte[] bytes, byte[] assinatura) {
        if (bytes == null || bytes.length < assinatura.length) {
            return false;
        }
        for (int indice = 0; indice < assinatura.length; indice++) {
            if (bytes[indice] != assinatura[indice]) {
                return false;
            }
        }
        return true;
    }
}
