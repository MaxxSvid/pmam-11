import { bootstrapApplication } from "@angular/platform-browser";
import { AppComponent } from "./app/app.component";
import { HTTP_INTERCEPTORS, provideHttpClient, withInterceptorsFromDi } from "@angular/common/http";
import { AppRoutingModule } from "./app/app-routing.module";
import { importProvidersFrom } from "@angular/core";
import { ReactiveFormsModule } from "@angular/forms";
import { provideStore } from "@ngrx/store";
import { userReducer } from "./app/core/modules/services/user.reducer";
import { AuthInterceptor } from "./app/core/modules/services/interceptor/auth-interceptor";


bootstrapApplication(AppComponent, {
  providers: [
    provideHttpClient(withInterceptorsFromDi()),
    AppRoutingModule,
    { provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true },
    importProvidersFrom(ReactiveFormsModule),
    provideStore({ user: userReducer })
  ]
})
  .catch(err => console.error(err))