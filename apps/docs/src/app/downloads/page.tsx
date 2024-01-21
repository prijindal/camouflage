import Link from "next/link";

const links = [
  {
    platform: "Android",
    link: "https://prijindal-github-builds.s3.amazonaws.com/prijindal/camouflage/main/android/app-release.apk",
  },
  {
    platform: "Linux",
    link: "https://prijindal-github-builds.s3.amazonaws.com/prijindal/camouflage/main/linux/linux.zip",
  },
  {
    platform: "Windows",
    link: "https://prijindal-github-builds.s3.amazonaws.com/prijindal/camouflage/main/windows/windows.zip",
  },
  {
    platform: "Web URL",
    link: "https://camouflage-14147.web.app/",
  },
  {
    platform: "Web Build",
    link: "https://prijindal-github-builds.s3.amazonaws.com/prijindal/camouflage/main/web/web.zip",
  },
];

type AndroidOutputMetadata = {
  version: number;
  artifactType: {
    type: string;
    kind: string;
  };
  applicationId: string;
  variantName: string;
  elements: {
    type: string;
    versionCode: number;
    versionName: string;
    outputFile: string;
  }[];
  elementType: string;
};

async function getData() {
  const res = await fetch(
    "https://prijindal-github-builds.s3.amazonaws.com/prijindal/camouflage/main/android/output-metadata.json"
  );
  // The return value is *not* serialized
  // You can return Date, Map, Set, etc.

  if (!res.ok) {
    // This will activate the closest `error.js` Error Boundary
    throw new Error("Failed to fetch data");
  }
  const metadata: AndroidOutputMetadata = await res.json();

  return {
    android: metadata,
  };
}

export default async function Downloads() {
  const { android } = await getData();

  return (
    <div>
      <table>
        <thead>
          <tr>
            <th>Platform</th>
            <th>URL</th>
            <th>Version</th>
          </tr>
        </thead>
        <tbody>
          {links.map(({ platform, link }) => (
            <tr key={platform}>
              <td>{platform}</td>
              <td>
                <Link href={link}>{link}</Link>
              </td>
              <td>{platform === "Android" ? android.elements[0].versionName : ""}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
