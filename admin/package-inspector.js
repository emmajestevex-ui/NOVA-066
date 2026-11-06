const MAGIC = new TextEncoder().encode("3105PATCH\0");

class BinaryPlistReader {
  constructor(bytes) {
    this.bytes = bytes instanceof Uint8Array ? bytes : new Uint8Array(bytes);
    this.objects = new Map();
    this.offsetSize = 0;
    this.referenceSize = 0;
    this.objectCount = 0;
    this.topObject = 0;
    this.offsetTableOffset = 0;
    this.offsets = [];
    this.prepare();
  }

  prepare() {
    if (this.bytes.length < 40 || decodeASCII(this.bytes.subarray(0, 8)) !== "bplist00") {
      throw new Error("El paquete no contiene un Property List binario valido.");
    }

    const trailer = this.bytes.subarray(this.bytes.length - 32);
    this.offsetSize = trailer[6];
    this.referenceSize = trailer[7];
    this.objectCount = readUnsigned(trailer, 8, 8);
    this.topObject = readUnsigned(trailer, 16, 8);
    this.offsetTableOffset = readUnsigned(trailer, 24, 8);

    if (!this.offsetSize || !this.referenceSize || !this.objectCount) {
      throw new Error("El Property List del paquete esta incompleto.");
    }
    if (this.objectCount > 200000 || this.offsetTableOffset >= this.bytes.length) {
      throw new Error("El Property List del paquete supera los limites permitidos.");
    }

    const tableEnd = this.offsetTableOffset + this.objectCount * this.offsetSize;
    if (tableEnd > this.bytes.length - 32) {
      throw new Error("La tabla del paquete esta incompleta.");
    }
    for (let index = 0; index < this.objectCount; index += 1) {
      this.offsets.push(readUnsigned(this.bytes, this.offsetTableOffset + index * this.offsetSize, this.offsetSize));
    }
  }

  parse() {
    return this.readObject(this.topObject);
  }

  readObject(index) {
    if (this.objects.has(index)) return this.objects.get(index);
    const offset = this.offsets[index];
    if (!Number.isInteger(offset) || offset >= this.bytes.length - 32) {
      throw new Error("El paquete contiene una referencia invalida.");
    }

    const marker = this.bytes[offset];
    const type = marker >> 4;
    const info = marker & 0x0f;
    let cursor = offset + 1;
    let value;

    if (type === 0x0) {
      value = info === 0x8 ? false : info === 0x9 ? true : null;
    } else if (type === 0x1) {
      const byteLength = 1 << info;
      value = readInteger(this.bytes, cursor, byteLength);
    } else if (type === 0x2) {
      const byteLength = 1 << info;
      if (cursor + byteLength > this.bytes.length) throw new Error("Numero real incompleto.");
      const view = new DataView(this.bytes.buffer, this.bytes.byteOffset + cursor, byteLength);
      value = byteLength === 4 ? view.getFloat32(0, false) : view.getFloat64(0, false);
    } else if (type === 0x3) {
      const byteLength = 1 << info;
      if (cursor + byteLength > this.bytes.length) throw new Error("Fecha incompleta.");
      const view = new DataView(this.bytes.buffer, this.bytes.byteOffset + cursor, byteLength);
      value = new Date((view.getFloat64(0, false) + 978307200) * 1000);
    } else if (type === 0x4) {
      const counted = this.readCount(info, cursor);
      value = this.readBytes(counted.next, counted.count);
    } else if (type === 0x5 || type === 0x6) {
      const counted = this.readCount(info, cursor);
      value = type === 0x5
        ? decodeASCII(this.bytes.subarray(counted.next, counted.next + counted.count))
        : decodeUTF16(this.bytes.subarray(counted.next, counted.next + counted.count * 2));
    } else if (type === 0x8) {
      const count = info === 0x0f ? 1 : info + 1;
      value = this.readBytes(cursor, count);
    } else if (type === 0xa) {
      const counted = this.readCount(info, cursor);
      const result = [];
      this.objects.set(index, result);
      for (let offsetIndex = 0; offsetIndex < counted.count; offsetIndex += 1) {
        result.push(this.readObject(readUnsigned(this.bytes, counted.next + offsetIndex * this.referenceSize, this.referenceSize)));
      }
      return result;
    } else if (type === 0xd) {
      const counted = this.readCount(info, cursor);
      const keyStart = counted.next;
      const valueStart = keyStart + counted.count * this.referenceSize;
      const result = {};
      this.objects.set(index, result);
      for (let keyIndex = 0; keyIndex < counted.count; keyIndex += 1) {
        const keyRef = readUnsigned(this.bytes, keyStart + keyIndex * this.referenceSize, this.referenceSize);
        const valueRef = readUnsigned(this.bytes, valueStart + keyIndex * this.referenceSize, this.referenceSize);
        const key = String(this.readObject(keyRef));
        result[key] = this.readObject(valueRef);
      }
      return result;
    } else {
      throw new Error(`Tipo de objeto Property List no compatible: ${type.toString(16)}`);
    }

    this.objects.set(index, value);
    return value;
  }

  readCount(info, cursor) {
    if (info !== 0x0f) return { count: info, next: cursor };
    const marker = this.bytes[cursor];
    const type = marker >> 4;
    const integerInfo = marker & 0x0f;
    if (type !== 0x1) throw new Error("La longitud del objeto no es un entero.");
    const byteLength = 1 << integerInfo;
    return { count: readUnsigned(this.bytes, cursor + 1, byteLength), next: cursor + 1 + byteLength };
  }

  readBytes(offset, length) {
    if (offset + length > this.bytes.length) throw new Error("Datos incompletos dentro del paquete.");
    return this.bytes.slice(offset, offset + length);
  }
}

export async function inspect3105Package(fileOrBuffer) {
  const buffer = fileOrBuffer instanceof ArrayBuffer
    ? fileOrBuffer
    : await fileOrBuffer.arrayBuffer();
  const bytes = new Uint8Array(buffer);
  if (bytes.length <= MAGIC.length || !sameBytes(bytes.subarray(0, MAGIC.length), MAGIC)) {
    throw new Error("Selecciona un archivo .3105 exportado desde NOVA.");
  }

  const envelope = new BinaryPlistReader(bytes.subarray(MAGIC.length)).parse();
  const packageID = uuidString(envelope.packageID);
  const schemaVersion = Number(envelope.schemaVersion || 0);
  const passwordProtected = Boolean(envelope.isPasswordProtected);
  if (!packageID || ![1, 2].includes(schemaVersion)) {
    throw new Error("El .3105 usa una version que NOVA no reconoce.");
  }
  if (passwordProtected) {
    return {
      packageID,
      schemaVersion,
      passwordProtected: true,
      patchCount: null,
      bundleIdentifiers: [],
      projectName: "",
    };
  }

  const contentKey = asBytes(envelope.publicContentKey);
  const sealed = asBytes(envelope.encryptedPayload);
  if (contentKey.length !== 32 || sealed.length < 28) {
    throw new Error("El .3105 no tiene una clave publica o payload valido.");
  }

  const nonce = sealed.slice(0, 12);
  const ciphertextAndTag = sealed.slice(12);
  const cryptoKey = await crypto.subtle.importKey("raw", contentKey, { name: "AES-GCM" }, false, ["decrypt"]);
  const aad = new TextEncoder().encode(`3105PATCH/v${schemaVersion}/payload/${packageID}`);
  let payloadBytes;
  try {
    payloadBytes = new Uint8Array(await crypto.subtle.decrypt(
      { name: "AES-GCM", iv: nonce, additionalData: aad, tagLength: 128 },
      cryptoKey,
      ciphertextAndTag,
    ));
  } catch {
    throw new Error("No pude verificar la firma interna del .3105. Puede estar dañado o alterado.");
  }

  const payload = new BinaryPlistReader(payloadBytes).parse();
  const project = payload?.project;
  const rules = Array.isArray(project?.rules) ? project.rules : [];
  const bundles = [
    ...(Array.isArray(project?.bundleIdentifiers) ? project.bundleIdentifiers : []),
    ...(Array.isArray(project?.directories) ? project.directories.map((item) => item?.bundleID) : []),
    ...rules.map((item) => item?.bundleID),
  ].map((value) => String(value || "").trim()).filter(Boolean);
  if (!rules.length) throw new Error("El .3105 no contiene ningún patch.");

  return {
    packageID,
    schemaVersion,
    passwordProtected: false,
    patchCount: rules.length,
    bundleIdentifiers: [...new Set(bundles)],
    projectName: String(project?.name || ""),
  };
}

function readUnsigned(bytes, offset, length) {
  if (offset + length > bytes.length || length > 8) throw new Error("Entero fuera del paquete.");
  let value = 0;
  for (let index = 0; index < length; index += 1) value = value * 256 + bytes[offset + index];
  return value;
}

function readInteger(bytes, offset, length) {
  const value = readUnsigned(bytes, offset, length);
  return Number.isSafeInteger(value) ? value : value.toString();
}

function asBytes(value) {
  if (value instanceof Uint8Array) return value;
  if (value instanceof ArrayBuffer) return new Uint8Array(value);
  if (Array.isArray(value)) return new Uint8Array(value);
  return new Uint8Array();
}

function uuidString(value) {
  const bytes = asBytes(value);
  if (bytes.length !== 16) return typeof value === "string" ? normalizeUUID(value) : "";
  const hex = Array.from(bytes, (byte) => byte.toString(16).padStart(2, "0")).join("");
  return normalizeUUID(hex);
}

function normalizeUUID(value) {
  const clean = String(value || "").replace(/[^a-f0-9]/gi, "").toUpperCase();
  if (clean.length !== 32) return "";
  return `${clean.slice(0, 8)}-${clean.slice(8, 12)}-${clean.slice(12, 16)}-${clean.slice(16, 20)}-${clean.slice(20)}`;
}

function sameBytes(left, right) {
  return left.length === right.length && left.every((value, index) => value === right[index]);
}

function decodeASCII(bytes) {
  return String.fromCharCode(...bytes);
}

function decodeUTF16(bytes) {
  const chars = [];
  for (let index = 0; index + 1 < bytes.length; index += 2) {
    chars.push(String.fromCharCode((bytes[index] << 8) | bytes[index + 1]));
  }
  return chars.join("");
}
