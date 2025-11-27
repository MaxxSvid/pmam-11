package com.example.todolist;

import android.app.AlertDialog;
import android.app.Dialog;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;

public class MainAdapter extends RecyclerView.Adapter<MainAdapter.ViewHolder> {

    private final List<Todo> todoList;

    public MainAdapter(List<Todo> todoList) {
        this.todoList = todoList;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_todo, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Todo todo = todoList.get(position);
        holder.bind(todo);
    }

    @Override
    public int getItemCount() {
        return todoList.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {

        private final TextView textView;
        private final ImageView btEdit;
        private final ImageView btDelete;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);

            textView = itemView.findViewById(R.id.text_view);
            btEdit = itemView.findViewById(R.id.bt_edit);
            btDelete = itemView.findViewById(R.id.bt_delete);

            btEdit.setOnClickListener(this);
            btDelete.setOnClickListener(this);
        }

        public void bind(Todo todo) {
            textView.setText(todo.getText());
        }

        @Override
        public void onClick(View v) {
            int position = getAdapterPosition();
            if (v == btEdit) {
                Todo todo = todoList.get(position);
                showEditDialog(todo, position);
            } else if (v == btDelete) {
                showDeleteDialog(position);
            }
        }

        private void showEditDialog(Todo todo, int position) {
            Dialog dialog = new Dialog(itemView.getContext());
            dialog.setContentView(R.layout.dialog_update);

            EditText editText = dialog.findViewById(R.id.edit_text);
            Button btUpdate = dialog.findViewById(R.id.bt_update);

            editText.setText(todo.getText());

            btUpdate.setOnClickListener(v -> {
                dialog.dismiss();
                String updatedText = editText.getText().toString().trim();

                if (updatedText.isEmpty()) {
                    return;
                }

                todo.setText(updatedText);
                notifyItemChanged(position);
            });

            int width = WindowManager.LayoutParams.MATCH_PARENT;
            int height = WindowManager.LayoutParams.WRAP_CONTENT;
            dialog.getWindow().setLayout(width, height);
            dialog.show();
        }

        private void showDeleteDialog(int position) {
            AlertDialog.Builder builder = new AlertDialog.Builder(itemView.getContext());
            builder.setMessage("Are you sure you want to delete this task?")
                    .setCancelable(false)
                    .setPositiveButton("Yes", (dialog, id) -> {
                        todoList.remove(position);
                        notifyItemRemoved(position);
                        notifyItemRangeChanged(position, todoList.size());
                    })
                    .setNegativeButton("No", (dialog, id) -> dialog.cancel());
            AlertDialog alert = builder.create();
            alert.setTitle("Delete Confirmation");
            alert.show();
        }
    }
}
