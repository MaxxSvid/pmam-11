import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { AbstractControl, FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router} from '@angular/router';
import { RegisterControls } from './interface/register-controls';
import { AuthService } from '../../../core/modules/services/auth-service';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [
    CommonModule,         
    ReactiveFormsModule   
  ],
  templateUrl: './register.component.html',
  styleUrl: './register.component.css'
})
export class RegisterComponent implements OnInit {
  registerForm!: FormGroup;
  serverError: string | null = null;
  submitting = false;

  constructor(private fb: FormBuilder, 
    private auth: AuthService, 
    private router: Router) {}

  ngOnInit(): void {
    this.registerForm = this.fb.group({
      userName: ['', [Validators.required, Validators.minLength(3)]],
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', Validators.required]
    }, { validators: this.passwordsMatch });
  }

 get f(): RegisterControls {
  return this.registerForm.controls as unknown as RegisterControls;
}

  private passwordsMatch(group: AbstractControl) {
    const p = group.get('password')?.value;
    const c = group.get('confirmPassword')?.value;
    return p === c ? null : { mismatch: true };
  }

  async onSubmit(): Promise<void> {
    if (this.registerForm.invalid) {
      this.registerForm.markAllAsTouched();
      return;
    }

    this.serverError = null;
    this.submitting = true;

    const dto = this.registerForm.value;
    try {
      const response = await this.auth.register(dto).toPromise();
      if (response?.success) {
        await this.router.navigate(['/urls-table']);
      }else{
        this.serverError = response?.message || 'Registration failed';
      }
    } catch (err: any) {
      if (err?.error?.errors) {
        this.serverError = Array.isArray(err.error.errors) ? err.error.errors.join('; ') : String(err.error.errors);
      } else {
        this.serverError = err?.error?.message ?? err?.message ?? 'Server error';
      }
    } finally {
      this.submitting = false;
    }
  }
  goToLogin(){
    this.router.navigate(['/login']);
  }
}

