package com.example.todolist;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.List;

public class TodoListFragment extends Fragment {

    private RecyclerView recyclerView;
    private MainAdapter adapter;
    private List<Todo> todoList;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_todo_list, container, false);
        recyclerView = view.findViewById(R.id.recycler_view);
        setUpRecyclerView();
        return view;
    }

    private void setUpRecyclerView() {
        LinearLayoutManager layoutManager = new LinearLayoutManager(getActivity());
        recyclerView.setLayoutManager(layoutManager);

        todoList = new ArrayList<>();
        adapter = new MainAdapter(todoList);

        recyclerView.setAdapter(adapter);
    }

    @SuppressLint("NotifyDataSetChanged")
    public void addTodoItem(Todo todo) {
        todoList.add(todo);
        adapter.notifyDataSetChanged();
    }

    @SuppressLint("NotifyDataSetChanged")
    public void clearTodoList() {
        todoList.clear();
        adapter.notifyDataSetChanged();
    }
}
