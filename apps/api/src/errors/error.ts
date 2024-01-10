export class CustomError {
  public class_name: string;
  constructor(
    public message: string,
    public status_code: number,
    public details: string
  ) {
    this.class_name = this.constructor.name;
  }
}
