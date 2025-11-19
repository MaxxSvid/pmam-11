package org.example.ui;

import javax.swing.*;
import java.awt.*;

public class ModernButton extends JButton {

    public enum Type {
        PRIMARY,
        SECONDARY,
        SUCCESS
    }

    private Color base;
    private Color hover;

    public ModernButton(String text, Type type) {
        super(text);

        setFont(new Font("Segoe UI", Font.PLAIN, 14));
        setFocusPainted(false);
        setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        setBorder(BorderFactory.createEmptyBorder(10, 14, 10, 14));
        setOpaque(true);

        switch (type) {
            case PRIMARY:
                base = new Color(70, 130, 255);
                hover = new Color(85, 145, 255);
                setForeground(Color.WHITE);
                break;

            case SUCCESS:
                base = new Color(50, 160, 70);
                hover = new Color(65, 180, 90);
                setForeground(Color.WHITE);
                break;

            default:
                base = new Color(40, 41, 46);
                hover = new Color(55, 56, 62);
                setForeground(new Color(220, 220, 220));
                break;
        }

        setBackground(base);

        addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseEntered(java.awt.event.MouseEvent evt) {
                setBackground(hover);
            }

            public void mouseExited(java.awt.event.MouseEvent evt) {
                setBackground(base);
            }
        });
    }
}
