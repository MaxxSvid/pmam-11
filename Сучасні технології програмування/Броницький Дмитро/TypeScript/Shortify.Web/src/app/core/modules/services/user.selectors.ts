import { createFeatureSelector, createSelector } from '@ngrx/store';
import { UserState } from './user.reducer';

export const selectUserState = createFeatureSelector<UserState>('user');
export const selectUser = createSelector(selectUserState, state => state.user);
export const selectUserId = createSelector(selectUserState, state => state.user?.id);
export const selectUserRole = createSelector(selectUserState, state => state.user?.role);