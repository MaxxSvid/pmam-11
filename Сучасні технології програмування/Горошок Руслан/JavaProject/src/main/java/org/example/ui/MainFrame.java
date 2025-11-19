package org.example.ui;

import org.example.core.FilterType;
import org.example.core.ImageProcessor;
import org.example.utils.FileHandler;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.image.BufferedImage;

public class MainFrame extends JFrame {

    private final ImageProcessor processor = new ImageProcessor();
    private BufferedImage originalImage;
    private BufferedImage currentImage;

    private ImagePanel canvas;
    private JScrollPane imageScroll;
    private JLabel zoomLabel;
    private double currentZoom = 1.0;

    // --- КОЛЬОРОВА ПАЛІТРА ---
    private final Color BG_COLOR = new Color(30, 30, 33);
    private final Color SIDEBAR_BG = new Color(40, 40, 44);
    private final Color PANEL_BG = new Color(50, 50, 55);
    private final Color ACCENT_COLOR = new Color(70, 130, 250);
    private final Color TEXT_PRIMARY = new Color(230, 230, 230);
    private final Color TEXT_SECONDARY = new Color(160, 160, 160);

    public MainFrame() {
        setTitle("Photo Studio Pro");
        setSize(1400, 900);
        setMinimumSize(new Dimension(1200, 800));
        setLocationRelativeTo(null);
        setDefaultCloseOperation(EXIT_ON_CLOSE);

        JPanel root = new JPanel(new BorderLayout());
        root.setBackground(BG_COLOR);

        // 1. Сайдбар
        root.add(createSidebar(), BorderLayout.WEST);

        // 2. Центральна частина (Фото)
        JPanel contentArea = new JPanel(new BorderLayout());
        contentArea.setBackground(BG_COLOR);
        contentArea.setBorder(new EmptyBorder(20, 20, 20, 20));

        canvas = new ImagePanel();
        canvas.setBackground(new Color(26, 26, 26));

        // Скрол-панель обмежує зображення. Воно не вилізе за межі цього компонента.
        imageScroll = new JScrollPane(canvas);
        imageScroll.setBorder(null);
        imageScroll.getViewport().setBackground(new Color(26, 26, 26));
        // Стиль рамки навколо фото
        imageScroll.setBorder(BorderFactory.createLineBorder(new Color(68, 68, 68), 1));


        imageScroll.setHorizontalScrollBarPolicy(ScrollPaneConstants.HORIZONTAL_SCROLLBAR_AS_NEEDED);
        imageScroll.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_AS_NEEDED);

        contentArea.add(imageScroll, BorderLayout.CENTER);

        // Зум панель
        JPanel bottomOverlay = new JPanel(new FlowLayout(FlowLayout.CENTER));
        bottomOverlay.setOpaque(false);
        bottomOverlay.add(createZoomCapsule());
        contentArea.add(bottomOverlay, BorderLayout.SOUTH);

        root.add(contentArea, BorderLayout.CENTER);

        // 3. Хедер
        root.add(createHeader(), BorderLayout.NORTH);

        setContentPane(root);
    }

    // ================= UI: САЙДБАР =================

    private JScrollPane createSidebar() {
        JPanel container = new JPanel();
        container.setLayout(new BoxLayout(container, BoxLayout.Y_AXIS));
        container.setBackground(SIDEBAR_BG);
        container.setBorder(new EmptyBorder(25, 20, 25, 20));

        // --- ЕФЕКТИ ---
        container.add(createSectionHeader("ЕФЕКТИ ТА ФІЛЬТРИ"));

        JPanel gridPanel = new JPanel(new GridLayout(0, 2, 12, 12));
        gridPanel.setBackground(SIDEBAR_BG);

        gridPanel.add(createStyledButton("Чорно-білий", () -> applyFilter(FilterType.GRAYSCALE)));
        gridPanel.add(createStyledButton("Сепія", () -> applyFilter(FilterType.SEPIA)));
        gridPanel.add(createStyledButton("Негатив", () -> applyFilter(FilterType.INVERT)));
        gridPanel.add(createStyledButton("Оберт 90°", () -> {
            if (currentImage != null) {
                currentImage = processor.rotateRight(currentImage);
                originalImage = deepCopy(currentImage);
                updateCanvas();
            }
        }));

        container.add(gridPanel);
        container.add(Box.createVerticalStrut(35));

        // --- КОРЕКЦІЯ ---
        container.add(createSectionHeader("КОЛІРНА КОРЕКЦІЯ"));

        JPanel slidersPanel = createRoundedPanel();
        slidersPanel.setLayout(new BoxLayout(slidersPanel, BoxLayout.Y_AXIS));

        addSlider(slidersPanel, "Яскравість", -100, 100, 0, (v, orig) -> processor.changeBrightness(orig, v));
        addSlider(slidersPanel, "Контраст", -100, 100, 0, (v, orig) -> processor.changeContrast(orig, v));
        addSlider(slidersPanel, "Насиченість", -100, 100, 0, (v, orig) -> processor.changeSaturation(orig, v));
        addSlider(slidersPanel, "Температура", -50, 50, 0, (v, orig) -> processor.changeTemperature(orig, v));

        container.add(slidersPanel);
        container.add(Box.createVerticalStrut(35));

        // --- ДЕТАЛІ ---
        container.add(createSectionHeader("ДЕТАЛІЗАЦІЯ"));

        JPanel detailsPanel = createRoundedPanel();
        detailsPanel.setLayout(new BoxLayout(detailsPanel, BoxLayout.Y_AXIS));

        addSlider(detailsPanel, "Різкість", 0, 50, 0, (v, orig) -> processor.sharpen(orig, v));
        addSlider(detailsPanel, "Розмиття", 0, 20, 0, (v, orig) -> processor.blur(orig, v));

        container.add(detailsPanel);

        // Фіксація ширини сайдбару
        JScrollPane scroll = new JScrollPane(container);
        scroll.setBorder(null);
        scroll.setHorizontalScrollBarPolicy(ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER);
        scroll.getVerticalScrollBar().setUnitIncrement(16);

        Dimension sidebarSize = new Dimension(420, 0);
        scroll.setPreferredSize(sidebarSize);
        scroll.setMinimumSize(sidebarSize);

        return scroll;
    }

    // ================= UI: ЕЛЕМЕНТИ =================

    private JLabel createSectionHeader(String text) {
        JLabel label = new JLabel(text);
        // --- ЦЕНТРУВАННЯ ЛЕЙБЛІВ ---
        label.setFont(new Font("Segoe UI", Font.BOLD, 12));
        label.setForeground(TEXT_SECONDARY);
        label.setBorder(new EmptyBorder(0, 0, 12, 0)); // Відступи
        label.setHorizontalAlignment(SwingConstants.CENTER); // Центрування тексту
        label.setAlignmentX(Component.CENTER_ALIGNMENT);   // Центрування компонента в BoxLayout
        return label;
    }

    private JButton createStyledButton(String text, Runnable action) {
        JButton btn = new JButton(text);
        btn.setFont(new Font("Segoe UI", Font.BOLD, 14));
        btn.setForeground(TEXT_PRIMARY);
        btn.setFocusPainted(false);
        btn.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        btn.setPreferredSize(new Dimension(0, 45));
        btn.addActionListener(e -> action.run());

        btn.putClientProperty("FlatLaf.style",
                "arc: 15; " +
                        "background: #353539; " +
                        "hoverBackground: #4A4A50; " +
                        "pressedBackground: #252528; " +
                        "borderWidth: 0; " +
                        "margin: 5,10,5,10"
        );
        return btn;
    }

    private JPanel createRoundedPanel() {
        JPanel panel = new JPanel();
        panel.setBackground(PANEL_BG);
        panel.putClientProperty("FlatLaf.style", "arc: 20; border: 15,15,15,15");
        return panel;
    }

    private void addSlider(JPanel panel, String name, int min, int max, int init, SliderHandler handler) {
        JPanel row = new JPanel(new BorderLayout(10, 0));
        row.setOpaque(false);
        row.setBorder(new EmptyBorder(0, 0, 15, 0));

        JLabel lblName = new JLabel(name);
        lblName.setForeground(new Color(200, 200, 200));
        lblName.setPreferredSize(new Dimension(90, 20));
        lblName.setFont(new Font("Segoe UI", Font.PLAIN, 13));

        JSlider slider = new JSlider(min, max, init);
        slider.setOpaque(false);
        slider.setFocusable(false);
        slider.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));

        JLabel lblValue = new JLabel(String.valueOf(init));
        lblValue.setForeground(ACCENT_COLOR);
        lblValue.setPreferredSize(new Dimension(35, 20));
        lblValue.setHorizontalAlignment(SwingConstants.RIGHT);
        lblValue.setFont(new Font("Monospaced", Font.BOLD, 13));

        slider.addChangeListener(e -> {
            lblValue.setText(String.valueOf(slider.getValue()));
            if (!slider.getValueIsAdjusting() && originalImage != null) {
                currentImage = handler.onSlide(slider.getValue(), originalImage);
                updateCanvas();
            }
        });

        row.add(lblName, BorderLayout.WEST);
        row.add(slider, BorderLayout.CENTER);
        row.add(lblValue, BorderLayout.EAST);

        panel.add(row);
    }

    // ================= UI: ХЕДЕР ТА НАЗВА ПРОГРАМИ =================

    private JPanel createHeader() {
        // Використовуємо BorderLayout, щоб рознести кнопки і назву по краях
        JPanel header = new JPanel(new BorderLayout());
        header.setBackground(BG_COLOR);
        header.setBorder(BorderFactory.createMatteBorder(0, 0, 1, 0, new Color(45, 45, 45)));

        // Внутрішня панель для відступів
        JPanel innerContainer = new JPanel(new BorderLayout());
        innerContainer.setBackground(BG_COLOR);
        innerContainer.setBorder(new EmptyBorder(15, 20, 15, 20));

        // ЛІВА ЧАСТИНА: Кнопки
        JPanel buttonsPanel = new JPanel(new FlowLayout(FlowLayout.LEFT, 15, 0));
        buttonsPanel.setOpaque(false);

        JButton btnOpen = createHeaderButton("Відкрити фото", ACCENT_COLOR);
        btnOpen.addActionListener(e -> loadPhoto());

        JButton btnSave = createHeaderButton("Зберегти", new Color(60, 60, 60));
        btnSave.addActionListener(e -> FileHandler.saveImage(this, currentImage));

        buttonsPanel.add(btnOpen);
        buttonsPanel.add(btnSave);

        // ПРАВА ЧАСТИНА: Красива назва програми
        JLabel titleLabel = new JLabel("PHOTO STUDIO PRO");
        titleLabel.setFont(new Font("Verdana", Font.BOLD, 22)); // Гарний шрифт
        titleLabel.setForeground(new Color(100, 100, 110)); // Стильний сірий колір
        // Або можна зробити акцентним: titleLabel.setForeground(ACCENT_COLOR);

        innerContainer.add(buttonsPanel, BorderLayout.WEST);
        innerContainer.add(titleLabel, BorderLayout.EAST);

        header.add(innerContainer, BorderLayout.CENTER);
        return header;
    }

    private JButton createHeaderButton(String text, Color bg) {
        JButton btn = new JButton(text);
        btn.setFont(new Font("Segoe UI", Font.BOLD, 14));
        btn.setForeground(Color.WHITE);
        btn.setBackground(bg);
        btn.setFocusPainted(false);
        btn.putClientProperty("FlatLaf.style", "arc: 10; border: 10,20,10,20");
        return btn;
    }

    private JPanel createZoomCapsule() {
        JPanel capsule = new JPanel(new FlowLayout(FlowLayout.CENTER, 5, 5));
        capsule.putClientProperty("FlatLaf.style", "arc: 999; background: #2D2D30; border: 1,1,1,1, #444444");

        JButton btnMinus = createZoomButton("−", () -> changeZoom(-0.1));
        JButton btnPlus = createZoomButton("+", () -> changeZoom(0.1));

        zoomLabel = new JLabel("100%");
        zoomLabel.setForeground(Color.WHITE);
        zoomLabel.setFont(new Font("Segoe UI", Font.BOLD, 14));
        zoomLabel.setPreferredSize(new Dimension(60, 30));
        zoomLabel.setHorizontalAlignment(SwingConstants.CENTER);
        zoomLabel.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                currentZoom = 1.0;
                updateCanvas();
            }
        });
        zoomLabel.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));

        capsule.add(btnMinus);
        capsule.add(zoomLabel);
        capsule.add(btnPlus);

        return capsule;
    }

    private JButton createZoomButton(String symbol, Runnable action) {
        JButton btn = new JButton(symbol);
        btn.setForeground(Color.WHITE);
        btn.setFont(new Font("Consolas", Font.BOLD, 18));
        btn.setFocusPainted(false);
        btn.setBorderPainted(false);
        btn.setContentAreaFilled(false);
        btn.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        btn.setPreferredSize(new Dimension(30, 30));
        btn.addMouseListener(new MouseAdapter() {
            public void mouseEntered(MouseEvent e) { btn.setForeground(ACCENT_COLOR); }
            public void mouseExited(MouseEvent e) { btn.setForeground(Color.WHITE); }
        });
        btn.addActionListener(e -> action.run());
        return btn;
    }

    // ================= ЛОГІКА =================

    private void loadPhoto() {
        BufferedImage img = FileHandler.openImage(this);
        if (img != null) {
            originalImage = img;
            currentImage = deepCopy(img);
            updateCanvas();
        }
    }

    private void applyFilter(FilterType type) {
        if (currentImage != null) {
            currentImage = processor.applyFilter(originalImage, type);
            updateCanvas();
        }
    }

    private void changeZoom(double delta) {
        currentZoom = Math.max(0.1, Math.min(10.0, currentZoom + delta));
        updateCanvas();
    }

    private void updateCanvas() {
        if (currentImage != null) {
            canvas.setImage(currentImage);
            canvas.setZoom(currentZoom);
            canvas.revalidate();
            canvas.repaint();
            zoomLabel.setText((int)(currentZoom * 100) + "%");
        }
    }

    private BufferedImage deepCopy(BufferedImage bi) {
        BufferedImage copy = new BufferedImage(bi.getWidth(), bi.getHeight(), bi.getType());
        Graphics g = copy.getGraphics();
        g.drawImage(bi, 0, 0, null);
        g.dispose();
        return copy;
    }

    private interface SliderHandler {
        BufferedImage onSlide(int value, BufferedImage original);
    }
}