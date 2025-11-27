package com.example.todolist;

import android.app.AlertDialog;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;

import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    private EditText editText;
    private Button addButton;
    private Button clearButton;
    private TodoListFragment todoListFragment;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        findViews();
        initFragment();
        setButtonListeners();
    }

    private void findViews() {
        editText = findViewById(R.id.edit_text);
        addButton = findViewById(R.id.bt_add);
        clearButton = findViewById(R.id.bt_clear);
    }

    private void initFragment() {
        todoListFragment = new TodoListFragment();
        getSupportFragmentManager()
                .beginTransaction()
                .add(R.id.fragment_container, todoListFragment)
                .commit();
    }

    private void setButtonListeners() {
        addButton.setOnClickListener(listener -> addTodoItem());

        clearButton.setOnClickListener(listener -> showClearDialog());
        clearButton.setEnabled(false);
    }

    private void addTodoItem() {
        String text = editText.getText().toString().trim();
        if (text.isEmpty()) {
            showErrorDialog();
            return;
        }

        Todo todo = new Todo();
        todo.setText(text);
        todoListFragment.addTodoItem(todo);

        editText.setText("");
        clearButton.setEnabled(true);
    }

    private void showErrorDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage("The text field must not be empty!")
                .setNeutralButton("OK", (dialog, which) -> dialog.dismiss())
                .create()
                .show();
    }

    private void showClearDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage("Are you sure you want to clear the list?")
                .setPositiveButton("Yes", (dialog, which) -> {
                    todoListFragment.clearTodoList();
                    clearButton.setEnabled(false);
                })
                .setNegativeButton("No", (dialog, which) -> dialog.dismiss())
                .create()
                .show();
    }
}
