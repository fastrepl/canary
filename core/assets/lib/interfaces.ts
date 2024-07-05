export interface Live {
  pushEvent: (
    event: string,
    input: { [key: string]: any },
    cb?: (output: { [key: string]: any }) => void,
  ) => void;
}
