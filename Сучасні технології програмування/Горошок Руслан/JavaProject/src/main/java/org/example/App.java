package org.example;

import com.formdev.flatlaf.themes.FlatMacDarkLaf;
import org.example.ui.MainFrame;

import javax.swing.*;

public class App {
    public static void main(String[] args) {
        try {
            UIManager.setLookAndFeel(new FlatMacDarkLaf());
            // Глобальні налаштування
            UIManager.put("Button.arc", 12);
            UIManager.put("Component.arc", 12);
            UIManager.put("TextComponent.arc", 12);
            UIManager.put("ScrollBar.width", 12);
        } catch (Exception ex) {
            System.err.println("Не вдалося завантажити тему!");
        }
        SwingUtilities.invokeLater(() -> new MainFrame().setVisible(true));
    }
}