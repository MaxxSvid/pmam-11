import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { Observable } from 'rxjs';
import { User } from '../../core/modules/interfaces/user.model';
import { Store } from '@ngrx/store';
import { UserState } from '../../core/modules/services/user.reducer';
import { clearUser } from '../../core/modules/services/user.actions';
import { RedirectService } from '../../core/modules/services/redirect-service';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.css']
})
export class HeaderComponent {
  currentUser$: Observable<User | null>;

  constructor(private store: Store<{ user: UserState }>,public redirectService: RedirectService) {
    this.currentUser$ = this.store.select(state => state.user.user);
  }

  logout() {
    this.store.dispatch(clearUser());
  }
}
