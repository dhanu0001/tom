package example;

public class HtmlSanitizer {
    public static String sanitize(String unsafeString) {
        if (unsafeString == null) return null;
        int len = unsafeString.length();
        StringBuilder result = new StringBuilder(len + 20);
        char aChar;

        for (int i = 0; i < len; ++i) {
            aChar = unsafeString.charAt(i);
            switch (aChar) {
                case '<': result.append("&lt;"); break;
                case '>': result.append("&gt;"); break;
                case '&': result.append("&amp;"); break;
                case '"': result.append("&quot;"); break;
                default:  result.append(aChar);
            }
        }

        return (result.toString());
    }
}
