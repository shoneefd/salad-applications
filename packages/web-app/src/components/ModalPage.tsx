import classNames from 'classnames'
import type { ReactNode } from 'react'
import { Component } from 'react'
import type { WithStyles } from 'react-jss'
import withStyles from 'react-jss'
import type { SaladTheme } from '../SaladTheme'

const styles = (theme: SaladTheme) => ({
  container: {
    position: 'fixed',
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    zIndex: 2000,
    backgroundColor: theme.darkBlue,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },
})

interface Props extends WithStyles<typeof styles> {
  onCloseClicked?: () => void
  children?: ReactNode
}

const bgId = 'modal-bg' + Math.random()

class _ModalPage extends Component<Props> {
  handleClose = (e: React.MouseEvent<HTMLDivElement, MouseEvent>) => {
    const { onCloseClicked } = this.props

    let tar = e.target as any as { id: string }

    if (onCloseClicked && tar.id === bgId) {
      onCloseClicked()
    }
  }
  public override render(): ReactNode {
    const { classes, children } = this.props
    return (
      <div id={bgId} className={classNames(classes.container)} onClick={this.handleClose}>
        {children}
      </div>
    )
  }
}

export const ModalPage = withStyles(styles)(_ModalPage)
