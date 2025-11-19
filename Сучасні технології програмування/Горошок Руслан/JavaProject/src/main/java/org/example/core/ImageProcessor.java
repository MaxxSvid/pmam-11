package org.example.core;

import java.awt.*;
import java.awt.image.BufferedImage;

public class ImageProcessor {

    // ------------ ФІЛЬТРИ --------------
    public BufferedImage applyFilter(BufferedImage original, FilterType type) {
        if (original == null) return null;

        int width = original.getWidth();
        int height = original.getHeight();
        BufferedImage result = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);

        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                Color c = new Color(original.getRGB(x, y));
                int r = c.getRed();
                int g = c.getGreen();
                int b = c.getBlue();
                Color newColor;

                switch (type) {
                    case GRAYSCALE -> {
                        int avg = (r + g + b) / 3;
                        newColor = new Color(avg, avg, avg);
                    }
                    case SEPIA -> {
                        int tr = clamp((int)(0.393*r + 0.769*g + 0.189*b));
                        int tg = clamp((int)(0.349*r + 0.686*g + 0.168*b));
                        int tb = clamp((int)(0.272*r + 0.534*g + 0.131*b));
                        newColor = new Color(tr, tg, tb);
                    }
                    case INVERT -> {
                        newColor = new Color(255-r, 255-g, 255-b);
                    }
                    default -> newColor = c;
                }

                result.setRGB(x, y, newColor.getRGB());
            }
        }
        return result;
    }

    // ------------ ОБЕРТАННЯ -------------
    public BufferedImage rotateRight(BufferedImage original) {
        if (original == null) return null;

        int w = original.getWidth();
        int h = original.getHeight();
        BufferedImage res = new BufferedImage(h, w, BufferedImage.TYPE_INT_RGB);

        for (int x = 0; x < w; x++) {
            for (int y = 0; y < h; y++) {
                res.setRGB(h - 1 - y, x, original.getRGB(x, y));
            }
        }
        return res;
    }

    // ------------ ЯСКРАВІСТЬ -------------
    public BufferedImage changeBrightness(BufferedImage original, int value) {
        if (original == null) return null;

        BufferedImage res = new BufferedImage(original.getWidth(), original.getHeight(), BufferedImage.TYPE_INT_RGB);

        for (int x = 0; x < original.getWidth(); x++) {
            for (int y = 0; y < original.getHeight(); y++) {
                Color c = new Color(original.getRGB(x, y));
                int r = clamp(c.getRed() + value);
                int g = clamp(c.getGreen() + value);
                int b = clamp(c.getBlue() + value);
                res.setRGB(x, y, new Color(r, g, b).getRGB());
            }
        }
        return res;
    }

    // ------------ КОНТРАСТ -------------
    public BufferedImage changeContrast(BufferedImage original, int value) {
        if (original == null) return null;

        float factor = (100f + value) / 100f;
        factor *= factor;

        BufferedImage res = new BufferedImage(original.getWidth(), original.getHeight(), BufferedImage.TYPE_INT_RGB);

        for (int x = 0; x < original.getWidth(); x++) {
            for (int y = 0; y < original.getHeight(); y++) {
                Color c = new Color(original.getRGB(x, y));
                int r = adjustContrast(c.getRed(), factor);
                int g = adjustContrast(c.getGreen(), factor);
                int b = adjustContrast(c.getBlue(), factor);
                res.setRGB(x, y, new Color(r, g, b).getRGB());
            }
        }
        return res;
    }

    private int adjustContrast(int color, float factor) {
        float res = (((color / 255f) - 0.5f) * factor + 0.5f) * 255f;
        return clamp((int) res);
    }

    // ------------ НАСИЧЕНІСТЬ -------------
    public BufferedImage changeSaturation(BufferedImage original, int value) {
        if (original == null) return null;

        float factor = 1 + (value / 100f);

        BufferedImage res = new BufferedImage(original.getWidth(), original.getHeight(), BufferedImage.TYPE_INT_RGB);

        for (int x = 0; x < original.getWidth(); x++) {
            for (int y = 0; y < original.getHeight(); y++) {
                Color c = new Color(original.getRGB(x, y));

                float[] hsb = Color.RGBtoHSB(c.getRed(), c.getGreen(), c.getBlue(), null);
                hsb[1] = Math.min(1f, Math.max(0f, hsb[1] * factor));

                int rgb = Color.HSBtoRGB(hsb[0], hsb[1], hsb[2]);
                res.setRGB(x, y, rgb);
            }
        }
        return res;
    }

    // ------------ ТЕМПЕРАТУРА -------------
    public BufferedImage changeTemperature(BufferedImage original, int value) {
        if (original == null) return null;

        int warm = value;
        int cool = -value;

        BufferedImage res = new BufferedImage(original.getWidth(), original.getHeight(), BufferedImage.TYPE_INT_RGB);

        for (int x = 0; x < original.getWidth(); x++) {
            for (int y = 0; y < original.getHeight(); y++) {
                Color c = new Color(original.getRGB(x, y));

                int r = clamp(c.getRed() + warm);
                int b = clamp(c.getBlue() + cool);

                res.setRGB(x, y, new Color(r, c.getGreen(), b).getRGB());
            }
        }
        return res;
    }

    // ------------ РІЗКІСТЬ -------------
    public BufferedImage sharpen(BufferedImage original, int value) {
        if (original == null) return null;

        float amount = value / 50f; // 0..2

        // Kernel різкості
        float[] kernel = {
                0, -amount,         0,
                -amount, 1 + 4*amount, -amount,
                0, -amount,         0
        };

        return applyKernel(original, kernel);
    }

    // ------------ РОЗМИТТЯ -------------
    public BufferedImage blur(BufferedImage original, int radius) {
        if (original == null) return null;
        if (radius == 0) return original;

        int size = radius * radius;
        float weight = 1f / size;
        float[] kernel = new float[size];

        for (int i = 0; i < size; i++) kernel[i] = weight;

        return applyKernel(original, kernel);
    }

    // ------------ ФУНКЦІЯ ОБРОБКИ КЕРНЕЛЕМ -------------
    private BufferedImage applyKernel(BufferedImage img, float[] kernel) {
        int w = img.getWidth();
        int h = img.getHeight();
        BufferedImage out = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);

        int kSize = (int) Math.sqrt(kernel.length);
        int kOffset = kSize / 2;

        for (int x = 0; x < w; x++) {
            for (int y = 0; y < h; y++) {

                float r = 0, g = 0, b = 0;

                for (int i = 0; i < kSize; i++) {
                    for (int j = 0; j < kSize; j++) {
                        int px = clampCoord(x + i - kOffset, w);
                        int py = clampCoord(y + j - kOffset, h);

                        Color c = new Color(img.getRGB(px, py));
                        float k = kernel[i * kSize + j];

                        r += c.getRed() * k;
                        g += c.getGreen() * k;
                        b += c.getBlue() * k;
                    }
                }

                out.setRGB(x, y, new Color(clamp((int) r), clamp((int) g), clamp((int) b)).getRGB());
            }
        }
        return out;
    }

    private int clampCoord(int val, int max) {
        return Math.max(0, Math.min(max - 1, val));
    }

    private int clamp(int val) {
        return Math.max(0, Math.min(255, val));
    }
}
