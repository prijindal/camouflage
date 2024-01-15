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

export default function Downloads() {
  return (
    <div>
      <table>
        <thead>
          <tr>
            <th>Platform</th>
            <th>URL</th>
          </tr>
        </thead>
        <tbody>
          {links.map(({ platform, link }) => (
            <tr key={platform}>
              <td>{platform}</td>
              <td>
                <Link href={link}>{link}</Link>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
