import { Component } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router,  } from '@angular/router';
import { AuthService } from '../../../core/modules/services/auth-service';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-login',
  standalone: true,
  templateUrl: './login.component.html',
   imports: [
    CommonModule,         
    ReactiveFormsModule   
  ],
  styleUrl: './login.component.css'
})
export class LoginComponent {
  loginForm!: FormGroup;
  serverError: string | null = null;
  submitting = false;

  constructor(
    private fb: FormBuilder,
    private auth: AuthService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.loginForm = this.fb.group({
      email: ['', Validators.required],
      password: ['', Validators.required]
    });
  }

  async onSubmit(): Promise<void> {
    if (this.loginForm.invalid) {
      this.loginForm.markAllAsTouched();
      return;
    }

    this.serverError = null;
    this.submitting = true;

    const dto = this.loginForm.value;
    try {
      const response = await this.auth.login(dto).toPromise();
      if (response?.success) {
        await this.router.navigate(['/urls-table']);
      } else {
        this.serverError = response?.message || 'Login failed';
      }  
    } catch (err: any) {
      this.serverError = err?.error?.message ?? err?.message ?? 'Server error';
    } finally {
      this.submitting = false;
    }
  }
  goToRegistration():void{
    this.router.navigate(['/registration']);
  }

}
