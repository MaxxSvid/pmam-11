import { AbstractControl } from "@angular/forms";

export type RegisterControls = {
  userName: AbstractControl;
  email: AbstractControl;
  password: AbstractControl;
  confirmPassword: AbstractControl;
};