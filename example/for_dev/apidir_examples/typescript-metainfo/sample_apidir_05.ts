import { apidir as bindoj } from "../public-packages/runtime/index";
import { ComplexTypesNotuple } from "../compile-tests/ex05_notuple_gen";

export const Sample_apidir_05InvpInfo = {
  "int-of-string": {
    name: "int-of-string",
    method: "POST",
    urlpath: "/option/int-of-string",
    requestType: undefined as unknown as String,
    responseType: undefined as unknown as number | null | undefined,
  },
  "option-of-complex": {
    name: "option-of-complex",
    method: "POST",
    urlpath: "/option/of-complex",
    requestType: undefined as unknown as ComplexTypesNotuple,
    responseType: undefined as unknown as number | null | undefined,
  },
} as const;
export type Sample_apidir_05InvpInfoMap = bindoj.IsApiDirInfoMap<typeof Sample_apidir_05InvpInfo>;
export type Sample_apidir_05ClientIntf = bindoj.ApiDirClientPromiseIntf<Sample_apidir_05InvpInfoMap>;