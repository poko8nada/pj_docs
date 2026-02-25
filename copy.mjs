// copy-to-project.mjs
import { execFile } from 'node:child_process'
import path from 'node:path'
import { promisify } from 'node:util'

const execFileAsync = promisify(execFile)

const DIR = process.cwd()
const HOME = process.env.HOME

const SrcDestCombinations = [
  {
    src: path.join(DIR, '.github/skills'),
    dest: path.join(DIR, '.claude/skills'),
  },
  {
    src: path.join(HOME, '.copilot/skills'),
    dest: path.join(HOME, '.config/opencode/skills'),
  },
]

async function rcloneCopy(src, dest) {
  console.log(`\n📦 Copying: ${src} → ${dest}`)
  try {
    const { stdout, stderr } = await execFileAsync('rclone', [
      'copy',
      src,
      dest,
      '--progress',
      '--log-level',
      'INFO',
    ])
    if (stdout) console.log(stdout)
    if (stderr) console.log(stderr)
    console.log(`✅ Done: ${src}`)
  } catch (err) {
    console.error(`❌ Failed: ${src}`)
    console.error(err.message)
    throw err
  }
}

async function main() {
  console.log('🚀 Starting copy process...')

  for (const { src, dest } of SrcDestCombinations) {
    await rcloneCopy(src, dest)
  }

  console.log('\n🎉 All done!')
}

main().catch(err => {
  console.error(err)
  process.exit(1)
})
