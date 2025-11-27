import { provideRouter, RouterModule, Routes } from "@angular/router";
import { LoginComponent } from "./domain/auth/login/login.component";
import { RegisterComponent } from "./domain/auth/register/register.component";
import { LayoutComponent } from "./layout/layout/layout.component";
import { UrlsTableComponent } from "./domain/urls-table/urls-table.component";
import { UrlInfoComponent } from "./domain/url-info/url-info.component";


const routes: Routes = [
  {
    path: '', component: LayoutComponent, children: [
      { path: '', redirectTo: 'urls-table', pathMatch: 'full' },
      { path: 'urls-table', component: UrlsTableComponent },
      { path: 'url-info/:id', component: UrlInfoComponent },
      { path: 'login', component: LoginComponent },
      { path: 'registration', component: RegisterComponent },
      
    ]
  }
];
export const AppRoutingModule = provideRouter(routes);
