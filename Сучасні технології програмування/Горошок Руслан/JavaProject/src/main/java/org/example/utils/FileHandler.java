package org.example.utils;

import javax.imageio.ImageIO;
import javax.swing.*;
import javax.swing.filechooser.FileNameExtensionFilter;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

public class FileHandler {

    public static BufferedImage openImage(Component parent) {
        JFileChooser chooser = new JFileChooser();
        chooser.setFileFilter(new FileNameExtensionFilter("Зображення (JPG, PNG)", "jpg", "png", "jpeg"));

        if (chooser.showOpenDialog(parent) == JFileChooser.APPROVE_OPTION) {
            try {
                return ImageIO.read(chooser.getSelectedFile());
            } catch (IOException e) {
                JOptionPane.showMessageDialog(parent, "Помилка читання файлу!");
            }
        }
        return null;
    }

    public static void saveImage(Component parent, BufferedImage image) {
        if (image == null) {
            JOptionPane.showMessageDialog(parent, "Спочатку відкрийте фото!");
            return;
        }
        JFileChooser chooser = new JFileChooser();
        chooser.setSelectedFile(new File("edited_photo.png"));

        if (chooser.showSaveDialog(parent) == JFileChooser.APPROVE_OPTION) {
            try {
                ImageIO.write(image, "PNG", chooser.getSelectedFile());
                JOptionPane.showMessageDialog(parent, "Успішно збережено!");
            } catch (IOException e) {
                JOptionPane.showMessageDialog(parent, "Помилка збереження!");
            }
        }
    }
}