package org.example.ui;

import javax.swing.*;
import java.awt.*;
import java.awt.image.BufferedImage;

public class ImagePanel extends JPanel {
    private BufferedImage image;
    private double zoom = 1.0;

    public void setImage(BufferedImage image) {
        this.image = image;
        updateSize();
        repaint();
    }

    public void setZoom(double zoom) {
        this.zoom = zoom;
        updateSize();
        repaint();
    }

    // Цей метод каже скролу, який розмір має панель.
    // Завдяки цьому скрол знає, коли вмикати полоси прокрутки.
    private void updateSize() {
        if (image != null) {
            int width = (int) (image.getWidth() * zoom);
            int height = (int) (image.getHeight() * zoom);
            setPreferredSize(new Dimension(width, height));
        } else {
            setPreferredSize(new Dimension(0, 0));
        }
        revalidate();
    }

    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        if (image != null) {
            Graphics2D g2 = (Graphics2D) g;

            // Згладжування для кращої якості при зумі
            g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);

            int width = (int) (image.getWidth() * zoom);
            int height = (int) (image.getHeight() * zoom);

            // Центрування, якщо картинка менша за вікно
            int x = (getWidth() - width) / 2;
            int y = (getHeight() - height) / 2;

            // Якщо картинка більша за вікно, малюємо від 0 (щоб працював скрол)
            // Це і є захист від того, щоб картинка "вилазила" куди не треба
            if (x < 0) x = 0;
            if (y < 0) y = 0;

            g2.drawImage(image, x, y, width, height, null);
        }
    }
}